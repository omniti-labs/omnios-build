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

PROG=pg_reorg
VER=1.1.7
VERHUMAN=$VER
PGVER=8415
PKG=omniti/database/postgresql-${PGVER}/pg_reorg
SUMMARY="$PROG - Reorganize database tables without locks"
DESC="$PROG can re-organize tables on a postgres database without any locks so that you can retrieve or update rows in tables being reorganized. The module is developed to be a better alternative of CLUSTER and VACUUM FULL."

DEPENDS_IPS="omniti/database/postgresql-$PGVER"

BUILDARCH=64
PREFIX=/opt/pgsql$PGVER
PATH=$PREFIX/bin:$PATH

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
