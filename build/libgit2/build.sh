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

PROG=libgit2
VER=0.19.0
VERHUMAN=$VER
PKG=omniti/library/developer/libgit2
SUMMARY="C API to git"
DESC=$SUMMARY

GIT_REPO=https://github.com/libgit2/libgit2.git
# XXX we're tied to this version until we can make php-git work with a
# later version.
GIT_REV=d18713fb4a
GIT=/usr/bin/git

BUILDARCH=64

PATH=/opt/omni/bin:$PATH
export PATH

BUILD_DEPENDS_IPS="omniti/developer/build/cmake"

download_git() {
    pushd $TMPDIR > /dev/null
    logmsg "Checking for source directory"
    if [ -d $BUILDDIR ]; then
        logmsg "--- removing previous source checkout"
        logcmd rm -rf $BUILDDIR
    fi
    logmsg "Checking out dtrace-provider from $GIT_REPO"
    logcmd $GIT clone $GIT_REPO $BUILDDIR
    if [ -n "$GIT_REV" ]; then
        pushd $BUILDDIR > /dev/null
        logcmd $GIT checkout $GIT_REV
        popd > /dev/null
    fi
    popd > /dev/null
}

CONFIGURE_CMD="/opt/omni/bin/cmake ."
CONFIGURE_OPTS_64="-DCMAKE_INSTALL_PREFIX=$PREFIX"

make_clean() {
    # Cmake doesn't have a distclean, so we just spike the cache file
    logmsg "--- make clean"
    logcmd $MAKE clean
    logcmd rm CMakeCache.txt
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
