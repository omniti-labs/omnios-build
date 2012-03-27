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

PROG=diffutils       # App name
VER=3.2        # App version
PVER=0.1           # Package Version
PKG=text/gnu-diffutils    # Package name (without prefix)
SUMMARY="GNU diffutils - Finds differences between and among files"
DESC="$SUMMARY"

DEPENDS_IPS="SUNWcs"

BUILDARCH=32
CONFIGURE_OPTS_32="--prefix=$PREFIX
        --sysconfdir=/etc
        --includedir=$PREFIX/include
        --bindir=$PREFIX/bin
        --sbindir=$PREFIX/sbin
        --libdir=$PREFIX/lib
        --libexecdir=$PREFIX/libexec
	--program-prefix=g"

link_up_gnu_sfw() {
    logmsg "Making links in /usr/gnu and /usr/sfw"
    logcmd mkdir -p $DESTDIR/usr/gnu/bin
    logcmd mkdir -p $DESTDIR/usr/gnu/share/man/man1
    for cmd in diff diff3 cmp sdiff
    do
        logcmd ln -s ../../bin/g$cmd $DESTDIR/usr/gnu/bin/$cmd
        logcmd ln -s ../../../../share/man/man1/g$cmd.1 $DESTDIR/usr/gnu/share/man/man1/$cmd.1
    done
}
init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
strip_install
link_up_gnu_sfw
make_package
clean_up
