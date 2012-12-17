#!/usr/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=dovecot
VER=2.1.12
VERHUMAN=$VER
PKG=omniti/network/dovecot
SUMMARY="the dovecot IMAP and POP server"
DESC="Dovecot is an open source IMAP and POP3 email server for Linux/UNIX-like systems, written with security primarily in mind. Dovecot is an excellent choice for both small and large installations. It's fast, simple to set up, requires no special administration and it uses very little memory."

copy_manifest() {
    logmsg "--- Copying SMF manifest"
    logcmd mkdir -p ${DESTDIR}/lib/svc/manifest/network
    logcmd cp $SRCDIR/files/dovecot.xml ${DESTDIR}/lib/svc/manifest/network
    logcmd mkdir -p ${DESTDIR}/lib/svc/method/
    logcmd cp $SRCDIR/files/dovecot.sh ${DESTDIR}/lib/svc/method
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
copy_manifest
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
