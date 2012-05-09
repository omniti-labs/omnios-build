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

PROG=mod_wsgi
VER=3.3
VERHUMAN=$VER
PKG=omniti/server/apache22/mod_wsgi
SUMMARY="Python WSGI adapter module for Apache 2.2"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="omniti/server/apache22" 
DEPENDS_IPS="omniti/runtime/python-26 system/library/gcc-4-runtime"

PREFIX=/opt/apache22/
BUILDARCH=64

LDFLAGS="-L/opt/python26/lib -R/opt/python26/lib $LDFLAGS"
CONFIGURE_OPTS="$CONFIGURE_OPTS --with-apxs=/opt/apache22/bin/$ISAPART64/apxs --with-python=/opt/python26/bin/python"

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
