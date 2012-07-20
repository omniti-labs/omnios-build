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

PROG=APC
VER=3.1.11
VERHUMAN=$VER
PKG=omniti/library/php-53/apc
SUMMARY="APC for php-53"
DESC="The Alternative PHP Cache (APC) is a free and open opcode cache for PHP. Its goal is to provide a free, open, and robust framework for caching and optimizing PHP intermediate code."

BUILD_DEPENDS_IPS="omniti/server/apache22
                   omniti/runtime/php-53
                   developer/build/autoconf"

DEPENDS_IPS="omniti/runtime/php-53"

PREFIX=/opt/php53
reset_configure_opts

CONFIGURE_OPTS=" \
  --prefix=$PREFIX \
  --enable-apc-mmap \
  --with-apxs=/opt/apache22/bin/apxs \
  --with-php-config=$PREFIX/bin/php-config"

LDFLAGS32="$LDFLAGS32 -L$PREFIX/lib -R$PREFIX/lib -L/opt/omni/lib -R/opt/omni/lib"
LDFLAGS64="$LDFLAGS64 -L/opt/omni/lib/amd64 -R/opt/omni/lib/amd64 -L$PREFIX/lib/amd64 -R$PREFIX/lib/amd64"

save_function configure64 configure64_orig

configure64() {
  logmsg "Running phpize..."
  logcmd $PREFIX/bin/phpize
  configure64_orig
}

make_install() {
  logmsg "--- make install"
  logcmd $MAKE DESTDIR=${DESTDIR} INSTALL_ROOT=${DESTDIR} install || \
    logerr "--- Make install failed"
}

build() {
       build64
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
