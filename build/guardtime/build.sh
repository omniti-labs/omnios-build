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

PROG=gtime
VER=1.0-12
VERHUMAN=$VER
PKG=omniti/security/guardtime
SUMMARY="Commandline client for Guardtime Keyless Signature Service"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="omniti/security/libguardtime"
DEPENDS_IPS="omniti/security/libguardtime"

CFLAGS="-I/opt/omni/include"
LDFLAGS="-L/opt/omni/lib -R/opt/omni/lib"
CFLAGS64="-I/usr/include/amd64 $CFLAGS64"
LDFLAGS64="-L/opt/omni/lib/amd64 -R/opt/omni/lib/amd64"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
VER=1.0.12
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
