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

PROG=mod_macro
VER=1.1.11
VERHUMAN=$VER
PKG=omniti/server/apache22/mod_macro
SUMMARY="$PROG for Apache 2.2"
DESC="allows the definition and use of macros (configuration templates) within apache runtime configuration files."
PREFIX=/opt/apache22

BUILD_DEPENDS_IPS="omniti/server/apache22"

BUILDARCH=64
APXS64=/opt/apache22/bin/amd64/apxs

build64() {
    pushd $TMPDIR/$BUILDDIR > /dev/null || logerr "--- failed to change directories tp build dir"
    logcmd $APXS64 -c mod_macro.c || \
        logerr "--- APXS failed"
    logcmd mkdir -p $DESTDIR`$APXS64 -q LIBEXECDIR` || \
        logerr "--- mkdir failed"
    logcmd cp .libs/mod_macro.so $DESTDIR`$APXS64 -q LIBEXECDIR`/mod_macro.so || \
        logerr "--- install failed"
    popd > /dev/null
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
