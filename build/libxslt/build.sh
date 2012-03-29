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

PROG=libxslt
VER=1.1.26
PKG=library/libxslt
SUMMARY="The XSLT library"
DESC="$SUMMARY"

DEPENDS_IPS="library/libxml2 library/zlib system/library system/library/math"

CFLAGS32="$CFLAGS32 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
CFLAGS64="$CFLAGS64 -D_LARGEFILE_SOURCE"
LDFLAGS="-lpthread"

CONFIGURE_OPTS="--disable-static --with-pic --with-threads --without-crypto"
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --with-python=/usr/bin/$ISAPART/python2.6"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --with-python=/usr/bin/$ISAPART64/python2.6"

NO_PARALLEL_MAKE="true"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up
