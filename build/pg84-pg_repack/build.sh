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

PROG=pg_repack
VER=1.1.8
VERHUMAN=$VER
PGVER=8416
PKG=omniti/database/postgresql-${PGVER}/pg_repack
SUMMARY="$PROG - Reorganize tables in PostgreSQL databases with minimal locks"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="omniti/database/postgresql-$PGVER"
DEPENDS_IPS="omniti/database/postgresql-$PGVER"

BUILDARCH=64
PREFIX=/opt/pgsql$PGVER
PATH=$PREFIX/bin:$PATH
TAR=gtar
BUILDDIR=${PROG}-ver_$VER

configure64() {
    logmsg "--- Skipping configure - not required"
}

export USE_PGXS=1
make_prog() {
    make_param prefix=$PREFIX
}
make_install() {
    make_param DESTDIR=${DESTDIR} prefix=$PREFIX install
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
