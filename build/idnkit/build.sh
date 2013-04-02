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

PROG=idnkit
VER=1.0-src
VERHUMAN=$VER
PKG=library/idnkit
SUMMARY="Internationalized Domain Name kit (idnkit/JPNIC)"
DESC="Internationalized Domain Name kit (idnkit/JPNIC)"

DEPENDS_IPS="system/library"

CONFIGURE_OPTS="--disable-static --mandir=/usr/share/man"
LIBTOOL_NOSTDLIB=libtool
LIBTOOL_NOSTDLIB_EXTRAS=-lc

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub

VER=${VER//-src/}

make_package lib.mog

PKG=library/idnkit/header-idnkit
DEPENDS_IPS=""
SUMMARY="Internationalized Domain Name Support Developer Files"
DESC="Internationalized Domain Name Support Developer Files"
make_package headers.mog

PKG=network/dns/idnconv
DEPENDS_IPS="library/idnkit"
SUMMARY="Internationalized Domain Name Support Utilities"
DESC="Internationalized Domain Name Support Utilities"
make_package bin.mog

clean_up

# Vim hints
# vim:ts=4:sw=4:et:
