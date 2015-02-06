#!/usr/bin/bash
#
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#

#
# Copyright 2015 OmniTI Computer Consulting, Inc.  All rights reserved.
#

# Load support functions
. ../../lib/functions.sh

PROG=devpro-libmtsk   # App name
VER=20060131       # App version
PKG=system/library/mtsk ##IGNORE##
SUMMARY="tmp summary (replaced below)"
DESC="$SUMMARY"

DEPENDS_IPS="system/library"

CONFIGURE_OPTS=""

build() {
    logmsg "--- cleaning residue from any previous build"
    rm -rf $TMPDIR/$BUILDDIR/scratch
    logmsg "--- Executing unified make process"
    PKGE=$(url_encode $PKG)
    DESTDIR=$DTMPDIR/mtsk_pkg
    mkdir -p $DESTDIR/lib/amd64
    install -m 0555 files/lib-libmtsk.so.1 $DESTDIR/lib/libmtsk.so.1
    install -m 0555 files/lib-libmtsk_db.so.1 $DESTDIR/lib/libmtsk_db.so.1
    install -m 0555 files/lib-amd64-libmtsk.so.1 $DESTDIR/lib/amd64/libmtsk.so.1
    install -m 0555 files/lib-amd64-libmtsk_db.so.1 $DESTDIR/lib/amd64/libmtsk_db.so.1
}

init
build

PKG=system/library/mtsk
VER=0.5.11
SUMMARY="Microtasking Libraries"
DESC="Microtasking Libraries"
make_package mtsk.mog

clean_up
