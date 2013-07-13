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

PROG=ntp
VER=dev-4.2.7p316
VERHUMAN=$VER
PKG=service/network/ntp
SUMMARY="Network Time Services"
DESC="$SUMMARY"

BUILDARCH=32

DEPENDS_IPS="SUNWcs library/security/openssl service/network/dns/mdns system/library/math system/library runtime/perl"

CFLAGS="$CFLAGS -std=c99 -D_XOPEN_SOURCE=600 -D__EXTENSIONS__"
CONFIGURE_OPTS_32="--prefix=/usr
    --bindir=/usr/sbin
    --with-binsubdir=sbin
    --libexecdir=/usr/lib/inet
    --sysconfdir=/etc/inet
    --enable-all-clocks
    --enable-debugging
    --enable-debug-timing
    --disable-optional-args
    --enable-parse-clocks
    --enable-ignore-dns-errors
    --without-ntpsnmpd
    --without-sntp
    --without-lineeditlibs
    --with-openssl-libdir=/lib
"

overlay_root() {
    logcmd rm -f $DESTDIR/usr/sbin/tickadj
    logcmd ln -s ntpdc $DESTDIR/usr/sbin/xntpdc
    (cd $SRCDIR/root && tar cf - .) | (cd $DESTDIR && tar xf -)
    logcmd mkdir -p $DESTDIR/var/ntp/ntpstats
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
overlay_root
make_isa_stub
VER=${VER//dev-/}
VER=${VER//p/.}
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
