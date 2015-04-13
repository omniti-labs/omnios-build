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

PROG=screen
VER=4.2.1
PKG=terminal/screen
SUMMARY="GNU Screen terminal multiplexer"
DESC="$SUMMARY"

BUILDARCH=32
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --bindir=/usr/bin --with-sys-screenrc=/etc/screenrc --enable-colors256 LDFLAGS=-lxnet"
gnu_cleanup() {
    logcmd rm $DESTDIR/usr/bin/screen
    logcmd mv $DESTDIR/usr/bin/screen-${VER} $DESTDIR/usr/bin/screen
    logcmd mv $DESTDIR/usr/man $DESTDIR/usr/share/
    logcmd mv $DESTDIR/usr/info $DESTDIR/usr/share/
}

save_function make_install make_install_orig
make_install() {
    make_install_orig
    logmsg "Installing etc/screenrc"
    logcmd mkdir $DESTDIR/etc || \
    	logerr "--- Failed to mkdir $DESTDIR/etc"
    logcmd cp etc/screenrc $DESTDIR/etc/ || \
    	logerr "--- Failed to copy screenrc"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
gnu_cleanup
strip_install
make_isa_stub
make_package
clean_up
