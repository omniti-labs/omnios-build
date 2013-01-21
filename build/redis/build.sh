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

PROG=redis
VER=2.6.9
VERHUMAN=$VER
PKG=omniti/database/redis
SUMMARY="Redis is an open source, advanced key-value store."
DESC="Redis is an open source, advanced key-value store. It is often referred to as a data structure server since keys can contain strings, hashes, lists, sets and sorted sets."

BUILD_DEPENDS_IPS="archiver/gnu-tar"

TAR=gtar
BUILDARCH=64
LDFLAGS="-m64"
CFLAGS="-m64"

configure64() {
    export CC CFLAGS LDFLAGS
}

make_install() {
    logmsg "--- install"
    mkdir -p $DESTDIR/$PREFIX/bin
    for i in redis-server redis-benchmark redis-cli; do
        cp $TMPDIR/$BUILDDIR/src/$i $DESTDIR/$PREFIX/bin
        chmod 0755 $DESTDIR/$PREFIX/bin/$i
    done
    mkdir -p $DESTDIR/$PREFIX/etc
    cp $TMPDIR/$BUILDDIR/redis.conf $DESTDIR/$PREFIX/etc/redis.conf.sample
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
