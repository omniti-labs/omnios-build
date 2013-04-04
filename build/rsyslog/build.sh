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
# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=rsyslog
VER=7.2.6
VERHUMAN=$VER
PKG=omniti/logging/rsyslog
SUMMARY="The enhanced syslogd for Linux and Unix"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="omniti/library/libee omniti/library/libestr omniti/library/json-c omniti/library/uuid"
DEPENDS_IPS="omniti/library/libee omniti/library/libestr omniti/library/json-c omniti/library/uuid"

BUILDARCH=64
CFLAGS="-I/opt/omni/include"
LDFLAGS64="-L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64"
LIBESTR_CFLAGS="$CFLAGS"
LIBESTR_LIBS="$LDFLAGS64 -lestr"
LIBEE_CFLAGS="$CFLAGS"
LIBEE_LIBS="$LDFLAGS64 -lee"
JSON_C_CFLAGS="$CFLAGS"
JSON_C_LIBS="$LDFLAGS64 -ljson-c"
LIBUUID_CFLAGS="$CFLAGS"
LIBUUID_LIBS="$LDFLAGS64 -luuid"
export LIBESTR_CFLAGS LIBESTR_LIBS \
       LIBEE_CFLAGS LIBEE_LIBS \
       JSON_C_CFLAGS JSON_C_LIBS \
       LIBUUID_CFLAGS LIBUUID_LIBS

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
