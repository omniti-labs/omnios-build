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
# Copyright 2014 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=cstore_fdw 
VER=0.0      
VERHUMAN=$VER 
PGVER=934
PKG=omniti/database/postgresql-${PGVER}/cstore_fdw
SUMMARY="$PROG - Column-oriented store for PostgreSQL"
DESC="$SUMMARY"

export CFLAGS=test
export C_INCLUDE_PATH=/opt/omni/include
export LD_LIBRARY_PATH=/opt/omni/lib/amd64

BUILDARCH=64
DEPENDS_IPS="omniti/database/postgresql-$PGVER"
BUILD_DEPENDS_IPS="$DEPENDS_IPS omniti/library/protobuf-c omniti/library/protobuf"

PREFIX=/opt/pgsql$PGVER
PATH=$PREFIX/bin:$PATH

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
