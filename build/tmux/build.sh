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

PROG=tmux
VER=1.7
VERHUMAN=$VER
PKG=terminal/tmux
SUMMARY="terminal multiplexer"
DESC="$SUMMARY"
LIBEVENT_VER=2.0.20
LDIR=libevent-${LIBEVENT_VER}-stable

BUILDARCH=32
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --bindir=/usr/bin"
CPPFLAGS="-I$TMPDIR/$PROG-$VER/$LDIR/include/event2 \
    -I$TMPDIR/$PROG-$VER/$LDIR/include"
CFLAGS="-std=c99 -D_XPG6 -D_POSIX_C_SOURCE=200112L"
LDFLAGS="-L$TMPDIR/$PROG-$VER/$LDIR/.libs -lsocket -lnsl -lsendfile"

save_function configure32 configure32_orig
configure32(){
  pushd $TMPDIR/$BUILDDIR/$LDIR > /dev/null
  logmsg "configuring libevent"
  logcmd ./configure --disable-static --disable-libevent-install || \
    logerr "failed libevent configure"
  logcmd "building a static libevent"
  logcmd make || logerr "failed libevent build"
  popd > /dev/null
  configure32_orig
}

init
download_source $PROG $PROG $VER
MAINBUILDDIR=$BUILDDIR
BUILDDIR=$LDIR
download_source libevent libevent ${LIBEVENT_VER}-stable $TMPDIR/$PROG-$VER
BUILDDIR=$MAINBUILDDIR
patch_source
prep_build
build
make_isa_stub
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
