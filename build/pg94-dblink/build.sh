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

PROG=postgresql
VER=9.4.2
VERHUMAN=$VER
PKG=omniti/database/postgresql-${VER//./}/dblink
DOWNLOADDIR=postgres
MODULE=dblink
CONTRIBDIR=contrib/$MODULE
SUMMARY="$PROG $MODULE - Executes A Query In A Remote Database for PostgreSQL $VER"
DESC="$SUMMARY"

BUILDARCH=64
CFLAGS="-O3"
CPPFLAGS="-I$TMPDIR/$PROG-$VER/src/backend"

PREFIX=/opt/pgsql${VER//./}
reset_configure_opts

CONFIGURE_OPTS="--enable-thread-safety
    --enable-debug
    --with-openssl
    --prefix=$PREFIX
    --without-readline"
# We don't want the default settings
CONFIGURE_OPTS_64=""

make_prog() {
    logmsg "--- make"
    logmsg "------ making fmgroids.h"
    logcmd $MAKE -C src/backend ../../src/include/utils/fmgroids.h || \
        logerr "------ make fmgroids.h failed"
    make_in src/interfaces/libpq
    make_in $CONTRIBDIR
}

make_install() {
    logmsg "--- make install"
    make_install_in $CONTRIBDIR
}

init
download_source $DOWNLOADDIR $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
