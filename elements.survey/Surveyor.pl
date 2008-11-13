#!/usr/bin/perl
use strict;
use warnings;
use File::Copy;

my $uuid = $ARGV[0];
$uuid = "test" unless $uuid;

my $dst_filename = "UserData-$uuid";

my $src_basepath = "$ENV{HOME}/Library/Application Support/Quicksilver/";
my $tmp_basepath = $src_basepath . "Backup/";
my $dst_basepath = $src_basepath . "$dst_filename/";

chdir $src_basepath;

mkdir $tmp_basepath;
mkdir $dst_basepath;

#Copy the files to backup
copy("$src_basepath/Mnemonics.plist", "$tmp_basepath/Mnemonics.plist");
copy("$src_basepath/Actions.plist", "$tmp_basepath/Actions.plist");
copy("$src_basepath/Catalog.plist", "$tmp_basepath/Catalog.plist");
copy("$ENV{HOME}/Library/Preferences/com.blacktree.Quicksilver.plist", "$tmp_basepath/Preferences.plist");
system("/usr/bin/plutil", "-convert", "xml1", "$tmp_basepath/Preferences.plist");
system("/bin/ls PlugIns > $tmp_basepath/PlugIns.txt");

my @filenames = ("Mnemonics.plist", "Actions.plist", "Preferences.plist", "Catalog.plist", "PlugIns.txt");

for my $filename (@filenames) {
    my $src_path = $tmp_basepath . $filename;
    my $dst_path = $dst_basepath . $filename;
    my ($src_file, $dst_file);
    open ($src_file, '<', $src_path) or next;
    open ($dst_file, '>', $dst_path) or next;
    my $counter=0;
    while (my $line = <$src_file> ) {
        # remove username 
        $line =~ s|/$ENV{USER}|/USERNAME|g;
        $line =~ s|/Users/[^/<]+|"/Users/USERNAME".($counter++)|eg;
        
        #remove volume names
        $line =~ s|/Volumes/[^/<]+|"/Volumes/VOLUMENAME".($counter++)|eg;
        
        #remove email addresses
        $line =~ s|[a-zA-Z_+.:]+\@[a-zA-Z_+.]+|"EMAILADDRESS".($counter++)|eg;
        
        print $dst_file $line;
    }
    close ($src_file);
    close ($dst_file);
}

system ("/usr/bin/tar", "-cjf", "$dst_filename.tbz2", $dst_filename);

#upload to textdrive
system ("/usr/bin/curl", "-F", "upload=\@$dst_filename.tbz2", "http://blacktree.textdriven.com/survey.php");
my $status = $? >> 8;

#remove the survey files
#system ("/bin/rm", "-r", $dst_filename);
system ("/bin/rm", "$dst_filename.tbz2");

exit $status;