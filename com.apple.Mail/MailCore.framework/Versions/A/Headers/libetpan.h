/*
 * libEtPan! -- a mail stuff library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * $Id: libetpan.h,v 1.17 2007/01/18 09:15:02 hoa Exp $
 */

#ifndef LIBETPAN_H

#define LIBETPAN_H

#ifdef __cplusplus
extern "C" {
#endif

#include "libetpan_version.h"
#include "maildriver.h"
#include "mailmessage.h"
#include "mailfolder.h"
#include "mailstorage.h"
#include "mailthread.h"
#include "mailsmtp.h"
#include "charconv.h"
#include "mailsem.h"
#include "carray.h"
#include "chash.h"
#include "maillock.h"
  
/* mbox driver */
#include "mboxdriver.h"
#include "mboxdriver_message.h"
#include "mboxdriver_cached.h"
#include "mboxdriver_cached_message.h"
#include "mboxstorage.h"

/* MH driver */
#include "mhdriver.h"
#include "mhdriver_message.h"
#include "mhdriver_cached.h"
#include "mhdriver_cached_message.h"
#include "mhstorage.h"

/* IMAP4rev1 driver */
#include "imapdriver.h"
#include "imapdriver_message.h"
#include "imapdriver_cached.h"
#include "imapdriver_cached_message.h"
#include "imapstorage.h"

/* POP3 driver */
#include "pop3driver.h"
#include "pop3driver_message.h"
#include "pop3driver_cached.h"
#include "pop3driver_cached_message.h"
#include "pop3storage.h"

/* Hotmail */
#include "hotmailstorage.h"

/* NNTP driver */
#include "nntpdriver.h"
#include "nntpdriver_message.h"
#include "nntpdriver_cached.h"
#include "nntpdriver_cached_message.h"
#include "nntpstorage.h"

/* maildir driver */
#include "maildirdriver.h"
#include "maildirdriver_message.h"
#include "maildirdriver_cached.h"
#include "maildirdriver_cached_message.h"
#include "maildirstorage.h"

/* db driver */
#include "dbdriver.h"
#include "dbdriver_message.h"
#include "dbstorage.h"

/* feed driver */
#include "feeddriver.h"
#include "feeddriver_message.h"
#include "feedstorage.h"

/* message which content is given by a MIME structure */
#include "mime_message_driver.h"

/* message which content given by a string */
#include "data_message_driver.h"

/* engine */
#include "mailprivacy.h"
#include "mailengine.h"
#include "mailprivacy_gnupg.h"
#include "mailprivacy_smime.h"

#ifdef __cplusplus
}
#endif

#endif
