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

PROG=php-memcache
VER=3.0.8
VERHUMAN=$VER
PHPVER=53
PKG=omniti/library/php-$PHPVER/memcache
SUMMARY="memcache extension for PHP"
DESC="provides an OO/procedural interface to memcache"

BUILDARCH=64
NO_PARALLEL_MAKE=true

PREFIX=/opt/php$PHPVER
reset_configure_opts

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --with-php-config=/opt/php$PHPVER/bin/php-config
    "
CFLAGS="-I/opt/omni/include"
BUILDDIR=memcache-$VER

make_install() {
    logmsg "--- make install"
    logcmd $MAKE INSTALL_ROOT=${DESTDIR} install || \
        logerr "--- Make install failed"
}

build64() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 64-bit"
    make_clean
    logmsg "--- Running phpize"
    logcmd /opt/php$PHPVER/bin/phpize || \
        logerr "--- phpize failed"
    configure64
    make_prog64
    make_install64
    popd > /dev/null
}

init
download_source memcache memcache $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
