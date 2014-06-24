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

PROG=protobuf-c
VER=1.0
VERHUMAN=$VER   # Human-readable version
PKG=omniti/library/protobuf-c
SUMMARY="Protobuf C library"
DESC="$SUMMARY ($VER)"

BUILD_DEPENDS_IPS="omniti/library/protobuf omniti/library/pkgconf developer/build/autoconf developer/build/automake developer/build/libtool"
DEPENDS_IPS="omniti/library/protobuf omniti/library/pkgconf"

CONFIGURE_OPTS="$CONFIGURE_OPTS --disable-protoc CXXFLAGS=-I/opt/omni/include"
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 LDFLAGS=-L/opt/omni/lib"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 LDFLAGS=-L/opt/omni/lib/amd64"

reconfig() {
  pushd $TMPDIR/$BUILDDIR || logerr "--- pushd $BUILDDIR failed"
  logcmd autoreconf -i || logerr "--- autoconf failed"
  popd || logerr "--- popd from $BUILDDIR failed"
}

init
download_source $PROG $PROG $VER
patch_source
reconfig
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
