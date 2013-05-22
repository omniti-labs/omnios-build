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

PROG=php-git
VER=0.2.2
VERHUMAN=$VER
PHPVER=53
PKG=omniti/library/php-$PHPVER/php-git
SUMMARY="libgit2 bindings for php"
DESC=$SUMMARY
BUILD_DEPENDS_IPS="omniti/library/developer/libgit2"
DEPENDS_IPS="omniti/library/developer/libgit2"

GIT_REPO=https://github.com/libgit2/php-git.git
GIT_REV=b28d1452f1
GIT=/usr/bin/git

BUILDARCH=64
NO_PARALLEL_MAKE=true

PREFIX=/opt/php$PHPVER
reset_configure_opts

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --with-php-config=/opt/php$PHPVER/bin/php-config
    "
CFLAGS="-I/opt/omni/include"
LDFLAGS64="$LDFLAGS64 -L/opt/omni/lib -R/opt/omni/lib -L$PREFIX/lib -R$PREFIX/lib"

download_git() {
    pushd $TMPDIR > /dev/null
    logmsg "Checking for source directory"
    if [ -d $BUILDDIR ]; then
        logmsg "--- removing previous source checkout"
        logcmd rm -rf $BUILDDIR
    fi
    logmsg "Checking out $PROG from $GIT_REPO"
    logcmd $GIT clone $GIT_REPO $BUILDDIR --recursive
    if [ -n "$GIT_REV" ]; then
        pushd $BUILDDIR > /dev/null
        logcmd $GIT checkout $GIT_REV
        popd > /dev/null
    fi
    popd > /dev/null
}

make_install() {
    logmsg "--- make install"
    logcmd $MAKE INSTALL_ROOT=${DESTDIR} install || \
        logerr "--- Make install failed"
}

build64() {
    mkdir $TMPDIR/$BUILDDIR/libgit2/build
    pushd $TMPDIR/$BUILDDIR/libgit2/build > /dev/null
    /opt/omni/bin/cmake -DCMAKE_INSTALL_PREFIX=$PREFIX ..
    /opt/omni/bin/cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_SHARED_LIBS=OFF -build .
    /usr/bin/make
    popd > /dev/null
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
download_git
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
