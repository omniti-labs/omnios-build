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
GPREFIX=$PREFIX/gnu
CONFIGURE_OPTS="
    --program-prefix=g
    --mandir=$GPREFIX/share/man
    --disable-overwrite
    --without-normal
    --with-shared
    --enable-widec
    --without-debug
    --includedir=$PREFIX/include/ncurses
    --prefix=$GPREFIX
"
CONFIGURE_OPTS_32="
    --bindir=$PREFIX/bin/$ISAPART"

CONFIGURE_OPTS_64="
    --bindir=$PREFIX/bin/$ISAPART64
    --libdir=$GPREFIX/lib/$ISAPART64"

gnu_links() {
    mkdir -p $DESTDIR/$GPREFIX/bin
    for cmd in captoinfo clear infocmp infotocap reset tic toe tput tset ; do
        ln -s ../../bin/g$cmd $DESTDIR/$GPREFIX/bin/$cmd
    done
    # put libncurses* in PREFIX/lib so other programs don't need to link with rpath
    mkdir -p $DESTDIR/$PREFIX/lib/$ISAPART64
    mv $DESTDIR/$GPREFIX/lib/libncurses* $DESTDIR/$PREFIX/lib
    mv $DESTDIR/$GPREFIX/lib/$ISAPART64/libncurses* $DESTDIR/$PREFIX/lib/$ISAPART64
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
