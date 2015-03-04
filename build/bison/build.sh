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

PROG=bison
VER=3.0.4
VERHUMAN=$VER
PKG=developer/parser/bison
SUMMARY="Bison is a general-purpose parser generator"
DESC="$SUMMARY"

BUILDARCH=32
CONFIGURE_OPTS_32="--prefix=$PREFIX
        --sysconfdir=/etc
        --includedir=$PREFIX/include
        --bindir=$PREFIX/bin
        --sbindir=$PREFIX/sbin
        --libdir=$PREFIX/lib
        --libexecdir=$PREFIX/libexec"
CONFIGURE_OPTS="--disable-yacc"
M4=/usr/bin/gm4
export M4

make_links() {
    logcmd mkdir -p $DESTDIR/usr/sfw/bin
    logcmd ln -s ../../bin/bison $DESTDIR/usr/sfw/bin/bison
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_links
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
