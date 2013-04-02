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

PROG=devpro-libm   # App name
VER=20060131       # App version
PKG=system/library/math ##IGNORE##
SUMMARY="tmp summary (replaced below)"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="sunstudio12.1"
DEPENDS_IPS="system/library"

CONFIGURE_OPTS=""

build() {
    logmsg "--- cleaning residue from any previous build"
    rm -rf $TMPDIR/$BUILDDIR/scratch
    logmsg "--- Executing unified make process"
    PKGE=$(url_encode $PKG)
    DESTDIR=$DTMPDIR/math_pkg
    pushd $TMPDIR/$BUILDDIR/usr/src/harness > /dev/null || logerr "can't enter build harness"
    logcmd make -f Makefile-os STUDIOBIN=/opt/sunstudio12.1/bin BUILDNAME=omni-os STATDIR=$TMPDIR/$BUILDDIR/scratch DESTDIR=$DESTDIR ||
        logerr "make/install failed"
    popd > /dev/null
}
links() {
    logmsg "--- Setting up symlinks"
    logcmd chmod 0755 $DESTDUR/usr
    logcmd mkdir -m 0755 $DESTDIR/usr/lib
    logcmd mkdir -m 0755 $DESTDIR/usr/lib/amd64
    logcmd ln -s ../../lib/libm.so.2 $DESTDIR/usr/lib/libm.so
    logcmd ln -s ../../lib/libm.so.1 $DESTDIR/usr/lib/libm.so.1
    logcmd ln -s ../../lib/libm.so.2 $DESTDIR/usr/lib/libm.so.2
    logcmd ln -s ../../lib/libmvec.so.1 $DESTDIR/usr/lib/libmvec.so
    logcmd ln -s ../../lib/libmvec.so.1 $DESTDIR/usr/lib/libmvec.so.1
    logcmd ln -s ../../../lib/amd64/libm.so.2 $DESTDIR/usr/lib/amd64/libm.so
    logcmd ln -s ../../../lib/amd64/libm.so.1 $DESTDIR/usr/lib/amd64/libm.so.1
    logcmd ln -s ../../../lib/amd64/libm.so.2 $DESTDIR/usr/lib/amd64/libm.so.2
    logcmd ln -s ../../../lib/amd64/libmvec.so.1 $DESTDIR/usr/lib/amd64/libmvec.so
    logcmd ln -s ../../../lib/amd64/libmvec.so.1 $DESTDIR/usr/lib/amd64/libmvec.so.1
    logcmd ln -s ../../lib/llib-lm $DESTDIR/usr/lib/llib-lm
    logcmd ln -s ../../lib/llib-lm.ln $DESTDIR/usr/lib/llib-lm.ln
    logcmd ln -s ../../../lib/amd64/llib-lm.ln $DESTDIR/usr/lib/amd64/llib-lm.ln
    logcmd ln -s ../usr/lib/cpp $DESTDIR/lib/cpp
}
install_license(){
    cp $TMPDIR/$BUILDDIR/usr/src/OPENSOLARIS.LICENSE $DESTDIR/license
}

init
download_source devpro $PROG src-$VER
patch_source
build
install_license
links

PKG=system/library/math
VER=0.5.11
SUMMARY="Math & Microtasking Libraries"
DESC="Math & Microtasking Libraries"
make_package math.mog

PKG=system/library/math/header-math
VER=0.5.11
SUMMARY="Math & Microtasking Library Headers & Lint Files"
DESC="Math & Microtasking Library Headers & Lint Files"
make_package headers.mog

clean_up
