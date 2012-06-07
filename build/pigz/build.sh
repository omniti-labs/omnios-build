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

PROG=pigz
VER=2.2.4
PKG=omniti/compress/pigz
SUMMARY="$PROG - parallel implementation of gzip"
DESC="$SUMMARY"

BUILDARCH=64

CFLAGS="-O3"
CFLAGS64="-I/opt/omni/include/$ISAPART64"
LDFLAGS64="-L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64"

configure64() {
    export PREFIX
    export DESTDIR
    export BINISA=$ISAPART64
    export CFLAGS="$CFLAGS $CFLAGS64"
    export LDFLAGS="$LDFLAGS $LDFLAGS64"
    export CC=$CC
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
