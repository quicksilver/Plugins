#!/usr/bin/perl -w
# Copyright © 2004 Jamie Zawinski <jwz@jwz.org>
#
# Permission to use, copy, modify, distribute, and sell this software and its
# documentation for any purpose is hereby granted without fee, provided that
# the above copyright notice appear in all copies and that both that
# copyright notice and this permission notice appear in supporting
# documentation.  No representations are made about the suitability of this
# software for any purpose.  It is provided "as is" without express or 
# implied warranty.
#
# Created:  3-Mar-2004 by Jamie Zawinski, Anonymous, and Jacob Post.
#
##############################################################################
#
# This is a program that can read the Mozilla URL history file --
# normally $HOME/.mozilla/default/*.slt/history.dat -- and prints out
# a list of URLs and their time of last access.  With no arguments,
# it prints lines like
#
#	1078333826	1	http://www.jwz.org/hacks/
#
# where the first number is a ctime (number of seconds since Jan 1 1970 GMT)
# and the second number is how many times this URL was visited.  The URLs are
# printed most-recent-first.
#
# With --verbose, it prints all the information known about each URL,
# including time of first visit, last visit, document title, etc.
#
# With --html, it produces HTML output instead of plain text.
#
# With "--age 2H", it limits itself to URLs that were loaded within the
# last two hours.  Likewise with "sec", "min", "day", "month", etc.
#
##############################################################################
#
# And Now, The Ugly Truth Laid Bare:
#
#   In Netscape Navigator 1.0 through 4.0, the history.db file was just a
#   Berkeley DBM file.  You could trivially bind to it from Perl, and
#   pull out the URLs and last-access time.  In Mozilla, this has been
#   replaced with a "Mork" database for which no tools exist.
#
#   Let me make it clear that McCusker is a complete barking lunatic.
#   This is just about the stupidest file format I've ever seen.
#
#       http://www.mozilla.org/mailnews/arch/mork/primer.txt
#       http://jwz.livejournal.com/312657.html
#       http://www.jwz.org/doc/mailsum.html
#       http://bugzilla.mozilla.org/show_bug.cgi?id=241438
#
#   In brief, let's count its sins:
#
#     - Two different numerical namespaces that overlap.
#
#     - It can't decide what kind of character-quoting syntax to use:
#       Backslash?  Hex encoding with dollar-sign?
#
#     - C++ line comments are allowed sometimes, but sometimes // is just
#       a pair of characters in a URL.
#
#     - It goes to all this serious compression effort (two different 
#       string-interning hash tables) and then writes out Unicode strings
#       without using UTF-8: writes out the unpacked wchar_t characters!
#
#     - Worse, it hex-encodes each wchar_t with a 3-byte encoding,
#       meaning the file size will be 3x or 6x (depending on whether
#       whchar_t is 2 bytes or 4 bytes.)
#
#     - It masquerades as a "textual" file format when in fact it's just
#       another binary-blob file, except that it represents all its magic
#       numbers in ASCII.  It's not human-readable, it's not hand-editable,
#       so the only benefit there is to the fact that it uses short lines
#       and doesn't use binary characters is that it makes the file bigger.
#       Oh wait, my mistake, that isn't actually a benefit at all.
#
# Pure comedy.
#
##############################################################################


require 5;
use diagnostics;
use strict;
use POSIX qw(strftime);

my $progname = $0; $progname =~ s@.*/@@g;
my $version = q{ $Revision: 2.11 $ }; $version =~ s/^[^0-9]+([0-9.]+).*$/$1/;

my $verbose = 0;
my $show_all_p = 1;

my (%key_table, %val_table, %row_hash);
my ($total, $skipped) = (0, 0);

# Returns a list of hashes, the contents of the mork file.
#
sub mork_parse_file {
  my ($file, $age) = @_;
  local $/ = undef;
  local *IN;

  my $since = ($age ? time() - $age : 0);

  ##########################################################################
  # Define the messy regexen up here
  ##########################################################################

  my $top_level_comment = qr@//.*\n@;

  my $key_table_re = qr/  < \s* <             # "< <"
                         \( a=c \) >          # "(a=c)>"
                         (?> ([^>]*) ) > \s*  # Grab anything that's not ">"
                     /sx;

  my $value_table_re = qr/ < ( .*?\) )> \s* /sx;

  my $table_re = qr/ \{ -?        # "{" or "{-"
                    [\da-f]+ :    # hex, ":"
                    (?> .*?\{ )   # Eat up to a {...
                   ((?> .*?\} )   # and then the closing }...
                    (?> .*?\} ))  # Finally, grab the table section
                 \s* /six;

  my $row_re = qr/ ( (?> \[ [^]]* \]  # "["..."]"
                         \s*)+ )      # Perhaps repeated many times
                 /sx;

  my $section_begin_re = qr/ \@\$\$\{    # "@$${"
                             ([\dA-F]+)  # hex
                             \{\@ \s*    # "{@"
                           /six;

  my $section_end_re = undef;
  my $section = "top level";

  ##########################################################################
  # Read in the file.
  ##########################################################################
  open (IN, "<$file") || error ("$file: $!");
  print STDERR "$progname: reading $file...\n" if ($verbose);

  my $body = <IN>;
  close IN;

  $body =~ s/\\\)/\$29/gs;  # close-paren is quoted with a backslash;
                            #  convert to hex.
  $body =~ s/\\\n//gs;      # backslash at end of line is continuation.

  ##########################################################################
  # Figure out what we're looking at, and parse it.
  ##########################################################################

  print STDERR "$progname: $file: parsing...\n" if ($verbose);

  pos($body) = 0;
  my $length = length($body);

  while( pos($body) < $length ) {

    # Key table

    if ( $body =~ m/\G$key_table_re/gc ) {
      mork_parse_key_table($file, $section, $1);

    # Values
    } elsif ( $body =~ m/\G$value_table_re/gco ) {
      mork_parse_value_table($file, $section, $1);

    # Table
    } elsif ( $body =~ m/\G$table_re/gco ) {
      mork_parse_table($file, $section, $age, $since, $1);

    # Rows (-> table)
    } elsif ( $body =~ m/\G$row_re/gco ) {
      mork_parse_table($file, $section, $age, $since, $1);

    # Section begin
    } elsif ( $body =~ m/\G$section_begin_re/gco ) {
      $section = $1;
      $section_end_re = qr/\@\$\$\}$section\}\@\s*/s;

    # Section end
    } elsif ( $section_end_re && $body =~ m/\G$section_end_re/gc ) {
      $section_end_re = undef;
      $section = "top level";

    # Comment
    } elsif ( $body =~ m/\G$top_level_comment/gco ) {
      #no-op

    } else {
#      $body =~ m/\G (.{0,300}) /gcsx; print "<$1>\n";
      error("$file: $section: Cannot parse");
    }
  }

  if($section_end_re) {
    error("$file: Unterminated section $section");
  }


  print STDERR "$progname: $file: sorting...\n" if ($verbose);

  my @entries = sort { $b->{LastVisitDate} <=>
                       $a->{LastVisitDate} } values(%row_hash);

  print STDERR "$progname: $file: done!  ($total total, $skipped skipped)\n"
    if ($verbose);

  (%key_table, %val_table, %row_hash, $total, $skipped) = ();

  return \@entries;
}


##########################################################################
# parse a row and column table
##########################################################################

sub mork_parse_table {
  my($file, $section, $age, $since, $table_part) = (@_);

  print STDERR "\n" if ($verbose > 3);

  # Assumption: no relevant spaces in values in this section
  $table_part =~ s/\s+//g;

#  print $table_part; #exit(0);

  #Grab each complete [...] block
  while( $table_part =~ m/\G  [^[]*   \[  # find a "["
                            ( [^]]+ ) \]  # capture up to "]"
                        /gcx ) {
    $_ = $1;

    my %hash;
    my ($id, @cells) = split (m/[()]+/s);

    next unless scalar(@cells);

    # Trim junk
    $id =~ s/^-//;
    $id =~ s/:.*//;

    if($row_hash{$id}) {
      %hash = ( %{$row_hash{$id}} );
    } else {
      %hash = ( 'ID'            => $id,
                'LastVisitDate' => 0   );
    }

    foreach (@cells) {
      next unless $_;

      my ($keyi, $which, $vali) =
        m/^\^ ([-\dA-F]+)
              ([\^=])
              (.*)     
          $/xi;

      error ("$file: unparsable cell: $_\n") unless defined ($vali);

      # If the key isn't in the key table, ignore it
      #
      my $key = $key_table{$keyi};
      next unless defined($key);

      my $val  = ($which eq '='
                  ? $vali
                  : $val_table{$vali});

      if ($key eq 'LastVisitDate' || $key eq 'FirstVisitDate') {
        $val = int ($val / 1000000);  # we don't need milliseconds, dude.
      }

      $hash{$key} = $val;
#print "$id: $key -> $val\n";
    }


    if ($age && ($hash{LastVisitDate} || $since) < $since) {
      print STDERR "$progname: $file: skipping old: " .
                   "$hash{LastVisitDate} $hash{URL}\n"
        if ($verbose > 3);
      $skipped++;
      next;
    }

    $total++;
    $row_hash{$id} = \%hash;
  }
}


##########################################################################
# parse a values table
##########################################################################

sub mork_parse_value_table {
  my($file, $section, $val_part) = (@_);

  return unless $val_part;

  my @pairs = split (m/\(([^\)]+)\)/, $val_part);
  $val_part = undef;

  print STDERR "\n" if ($verbose > 3);

  foreach (@pairs) {
    next unless (m/[^\s]/s);
    my ($key, $val) = m/([\dA-F]*)[\t\n ]*=[\t\n ]*(.*)/i;

    if (! defined ($val)) {
      print STDERR "$progname: $file: $section: unparsable val: $_\n";
      next;
    }

    # Assume that URLs and LastVisited are never hexilated; so
    # don't bother unhexilating if we won't be using Name, etc.
    if($show_all_p && $val =~ m/\$/) {
      # Approximate wchar_t -> ASCII and remove NULs
      $val =~ s/\$00//g;  # faster if we remove these first
      $val =~ s/\$([\dA-F]{2})/chr(hex($1))/ge;
    }

    $val_table{$key} = $val;
    print STDERR "$progname: $file: $section: val $key = \"$val\"\n"
      if ($verbose > 3);
  }
}


##########################################################################
# parse a key table
##########################################################################

sub mork_parse_key_table {
  my ($file, $section, $key_table) = (@_);

  print STDERR "\n" if ($verbose > 3);
  $key_table =~ s@\s+//.*$@@gm;

  my @pairs = split (m/\(([^\)]+)\)/s, $key_table);
  $key_table = undef;

  foreach (@pairs) {
    next unless (m/[^\s]/s);
    my ($key, $val) = m/([\dA-F]+)\s*=\s*(.*)/i;
    error ("$file: $section: unparsable key: $_") unless defined ($val);

    # If we're only emitting URLs and dates, don't even bother
    # saving the other fields that we aren't interested in.
    #
    next if (!$show_all_p &&
             $val ne 'URL' && $val ne 'LastVisitDate' &&
             $val ne 'VisitCount');

    $key_table{$key} = $val;
    print STDERR "$progname: $file: $section: key $key = \"$val\"\n"
      if ($verbose > 3);
  }
}


sub html_quote {
  my ($s) = @_;
  $s =~ s/&/&amp;/g;
  $s =~ s/</&lt;/g;
  $s =~ s/>/&gt;/g;
  $s =~ s/\"/&quot;/g;
  return $s;
}

sub html_wrap {
  my ($s) = @_;
  $s = html_quote ($s);

  # while there are non-wrappable chunks of 30 characters,
  # insert wrap points at certain punctuation characters every 10 characters.
  while ($s =~ m/[^\s]{30}/s) {
    last unless ($s =~ s@([^\s]{10})([/;,])([^/\s])@$1$2 $3@gs ||
                 $s =~ s@([^\s]{10})([-_\$\#?.]|&amp;|%(2F|2C|26))@$1 $2@gs);
  }

  # if we still have non-wrappable chunks of 40 characters,
  # insert wrap points every 30 characters no matter what.
  while ($s =~ m/[^\s]{40}/s) {
    last unless ($s =~ s@([^\s]{30})@$1 @gs);
  }

  return $s;
}

sub format_urls {
  my ($results, $html_p) = @_;

  print "<TABLE BORDER=0 CELLPADDING=" . ($show_all_p ? "4" : "0") .
              " CELLSPACING=0>\n"
    if ($html_p);

  foreach my $hash (@$results) {

    if ($show_all_p) {
      #
      # Print every field in the hash.
      #

      if ($html_p) {
        print " <TR>\n";
        print "  <TD NOWRAP ALIGN=RIGHT VALIGN=TOP>$hash->{ID}&nbsp;</TD>\n";
        print "  <TD NOWRAP>\n";
        print "   <TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0>\n";
      }

      my %key_sort_table = (
        'ID'		  => ' 0 ',
        'URL'		  => ' 1 ',
        'Name'		  => ' 2 ',
        'Hostname'	  => ' 3 ',
        'FirstVisitDate'  => ' 4 ',
        'LastVisitDate'	  => ' 5 '
      );

      foreach my $key (sort { ($key_sort_table{$a} || $a) cmp
                              ($key_sort_table{$b} || $b)
                            } (keys(%$hash))) {
        my $val = $hash->{$key};
        if ($key eq 'LastVisitDate' || $key eq 'FirstVisitDate') {
          $val = localtime ($val);
        }
        if ($html_p) {
          next if ($key eq 'ID');
          $key = html_quote ($key);
          $val = ($key eq 'URL'
                  ? "<A HREF=\"$val\">" . html_wrap ($val) . "</A>"
                  : html_wrap ($val));
          print "    <TR>\n";
          print "     <TD VALIGN=TOP NOWRAP ALIGN=RIGHT>$key: &nbsp;</TD>\n";
          print "     <TD VALIGN=TOP>$val</TD>\n";
          print "    </TR>\n";
        } else {
          print sprintf ("%14s = %s\n", $key, $val);
        }
      }

      if ($html_p) {
        print "   </TABLE>\n";
        print "  </TD>\n";
        print " </TR>\n";
      }
      print "\n";

    } else {
      #
      # Print just the URLs and their last-load-times.
      #
      my $url   = $hash->{'URL'};
      my $date  = $hash->{'LastVisitDate'} || 0;
      my $count = $hash->{'VisitCount'} || 1;
      next unless defined ($url);

      if ($html_p) {
        $date = strftime("%d %b %l:%M %p", localtime ($date));
        my $u2 = html_wrap ($url);
        print " <TR>";
        print "<TD VALIGN=TOP ALIGN=RIGHT NOWRAP>";
        print "($count) " if ($count > 1);
        print "$date &nbsp;</TD>";
        print "<TD VALIGN=TOP><A HREF=\"$url\">$u2</A></TD>";
        print "</TR>\n";
      } else {
        print "$date\t$count\t$url\n";
      }
    }
  }

  print "</TABLE>\n" if ($html_p);
}


sub error {
  ($_) = @_;
  print STDERR "$progname: $_\n";
  exit 1;
}

sub usage {
  print STDERR "usage: $progname [--verbose] [--html] [--age secs] " .
                    "mork-input-file\n" .
    "\t'age' can be of the form '2h', '3d', etc.\n";
  exit 1;
}

sub main {
  my ($file, $age, $html_p);
  while ($#ARGV >= 0) {
    $_ = shift @ARGV;
    if ($_ eq "--verbose") { $verbose++; }
    elsif (m/^-v+$/) { $verbose += length($_)-1; }
    elsif ($_ eq "--age") { $age = shift @ARGV; }
    elsif ($_ eq "--html") { $html_p = 1; }
    elsif (m/^-./) { usage; }
    elsif (!defined($file)) { $file = $_; }
    else { usage; }
  }

  usage() unless defined($file);

  $show_all_p = ($verbose > 1);

  if (!$age) {
  } elsif ($age =~ m/^(\d+)\s*s(ec(onds?)?)?$/i) {
    $age = $1 + 0;
  } elsif ($age =~ m/^(\d+)\s*m(in(utes?)?)?$/i) {
    $age = $1 * 60;
  } elsif ($age =~ m/^(\d+)\s*h(ours?)?$/i) {
    $age = $1 * 60 * 60;
  } elsif ($age =~ m/^(\d+)\s*d(ays?)?$/i) {
    $age = $1 * 60 * 60 * 24;
  } elsif ($age =~ m/^(\d+)\s*w(eeks?)?$/i) {
    $age = $1 * 60 * 60 * 24 * 7;
  } elsif ($age =~ m/^(\d+)\s*m(on(ths?)?)?$/i) {
    $age = $1 * 60 * 60 * 24 * 30;
  } elsif ($age =~ m/^(\d+)\s*y(ears?)?$/i) {
    $age = $1 * 60 * 60 * 24 * 365;
  } else {
    error ("unparsable: --age $age");
  }

  my $results = mork_parse_file ($file, $age);
  format_urls ($results, $html_p);
}

main;
exit 0;
