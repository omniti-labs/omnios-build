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
VER=9.1.3
VERHUMAN=$VER
PKG=omniti/library/libpq5
SUMMARY="PostgreSQL Libs (libpq.so.5)"
DESC="Use this package if you just need to link and/or build against libpq"

DOWNLOADDIR=postgres
DEPENDS_IPS="system/library/gcc-4-runtime"

CFLAGS="-O3"
CPPFLAGS="-D_REENTRANT"

CONFIGURE_OPTS="
    --enable-thread-safety
    --enable-debug
    --with-openssl
    --without-readline
"

# Which directories should we make/make install in?
MAKE_DIRS="src/include src/interfaces/libpq src/makefiles src/port src/backend
    src/bin/pg_config"
INSTALL_DIRS="src/include src/interfaces/libpq src/makefiles src/port
    src/bin/pg_config"

make_prog() {
    logmsg "--- make"
    for d in $MAKE_DIRS; do make_in $d; done
}

make_install() {
    logmsg "--- make install"
    for d in $INSTALL_DIRS; do make_install_in $d; done
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
