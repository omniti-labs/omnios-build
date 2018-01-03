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
# Copyright 2017 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=curl       # App name
VER=7.57.0      # App version
PKG=web/curl    # Package name (without prefix)
SUMMARY="$PROG - command line tool for transferring data with URL syntax"
DESC="$SUMMARY"

DEPENDS_IPS="web/ca-bundle library/security/openssl@1.0.2 library/zlib
    library/libidn library/nghttp2"

CONFIGURE_OPTS="--enable-thread --with-ca-bundle=/etc/ssl/cacert.pem"
# curl actually has arch-dependent headers. Boo.
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --includedir=$PREFIX/include/amd64"

LIBTOOL_NOSTDLIB=libtool

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up
