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

PROG=ncurses
VER=5.9
VERHUMAN=$VER
PKG=library/ncurses
SUMMARY="A CRT screen handling and optimization package."
DESC="$SUMMARY"

DEPENDS_IPS="shell/bash system/library"

CPPFLAGS='-std=c99'
CFLAGS="-std=c99"
LD=/usr/ccs/bin/ld
export LD
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --libdir=/usr/gnu/lib"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --libdir=/usr/gnu/lib/$ISAPART64"
CONFIGURE_OPTS="
    --program-prefix=g
    --prefix=/usr/gnu
    --mandir=/usr/gnu/share/man
    --includedir=/usr/include/ncurses
    --with-normal
    --with-shared
    --enable-rpath
    --enable-widec
    --without-debug
"

gnu_links() {
    mkdir $DESTDIR/usr/gnu/bin
    mkdir $DESTDIR/usr/gnu/bin/{i386,amd64}
    mv $DESTDIR/usr/bin/ncurses5-config $DESTDIR/usr/gnu/bin/
    mv $DESTDIR/usr/bin/i386/ncurses5-config $DESTDIR/usr/gnu/bin/i386/
    mv $DESTDIR/usr/bin/amd64/ncurses5-config $DESTDIR/usr/gnu/bin/amd64/
    for cmd in captoinfo clear infocmp infotocap reset tic toe tput tset ; do
        ln -s ../../bin/g$cmd $DESTDIR/usr/gnu/bin/$cmd
    done
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
gnu_links
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
