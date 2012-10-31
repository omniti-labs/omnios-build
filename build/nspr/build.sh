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

PROG=nspr
VER=4.9.3
VERHUMAN=$VER
PKG=$PROG ##IGNORE##
SUMMARY="Netscape Portable Runtime"      # You should change this
DESC="$SUMMARY"         # Longer description

CONFIGURE_OPTS="--includedir=/usr/include/mps"
CONFIGURE_OPTS_32="--libdir=/usr/lib/mps"
CONFIGURE_OPTS_64="--libdir=/usr/lib/mps/$ISAPART64 --enable-64bit"

secv1_links() {
    logcmd ln -s amd64 $DESTDIR/usr/lib/mps/64
    logcmd mkdir -p $DESTDIR/usr/lib/mps/secv1/amd64
    logcmd ln -s amd64 $DESTDIR/usr/lib/mps/secv1/64
    logcmd mkdir -p $DESTDIR/usr/lib/pkgconfig
    logcmd cp $SRCDIR/files/nspr.pc $DESTDIR/usr/lib/pkgconfig
    for lib in libnspr4.so libplc4.so libplds4.so
    do
        ln -s ../../amd64/$lib $DESTDIR/usr/lib/mps/secv1/amd64/$lib
        ln -s ../$lib $DESTDIR/usr/lib/mps/secv1/$lib
    done
}

init
download_source $PROG $PROG $VER
BUILDDIR=$PROG-$VER/mozilla/nsprpub
patch_source
prep_build
build
secv1_links
make_isa_stub

PKG=library/nspr/header-nspr
SUMMARY="Netscape Portable Runtime Headers"
DESC="$SUMMARY"
make_package header-nspr.mog

DEPENDS_IPS="SUNWcs system/library/gcc-4-runtime system/library"
PKG=library/nspr
SUMMARY="Netscape Portable Runtime"
DESC="$SUMMARY"
make_package nspr.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
