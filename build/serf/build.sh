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

PROG=serf
VER=1.1.0
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=omniti/library/serf
SUMMARY="serf WebDav client library"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="developer/swig omniti/library/apr omniti/library/apr-util"
DEPENDS_IPS="omniti/library/apr-util"

CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32
    --includedir=/opt/omni/include/serf-1
    --with-apr=/opt/omni/bin/$ISAPART/apr-1-config
    --with-apr-util=/opt/omni/bin/$ISAPART/apu-1-config"

CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64
    --includedir=/opt/omni/include/amd64/serf-1
    --with-swig=/usr/bin/$ISAPART64/swig
    --with-apr=/opt/omni/bin/$ISAPART64/apr-1-config
    --with-apr-util=/opt/omni/bin/$ISAPART64/apu-1-config"

CPPFLAGS32="-D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE \
    $CPPFLAGS32 -I/opt/omni/include"
CPPFLAGS64="$CPPFLAGS64 -I/opt/omni/include/amd64" 

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
