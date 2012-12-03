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

PROG=node-dtrace
VER=0.2.4
PKG=omniti/runtime/nodejs/node-dtrace
SUMMARY="DTrace provider for node.js"
DESC="$SUMMARY"

REPO_NODEDTRACE=https://github.com/chrisa/node-dtrace-provider.git
REV_NODEDT=7eba54004a
REPO_LIBUSDT=https://github.com/chrisa/libusdt.git
REV_LIBUSDT=68f085755b
GIT=/usr/bin/git

BUILDARCH=64

PATH=/opt/omni/bin:$PATH
export PATH

BUILD_DEPENDS_IPS="omniti/runtime/nodejs"
DEPENDS_IPS="omniti/runtime/nodejs"

download_git() {
    pushd $TMPDIR > /dev/null
    logmsg "Checking for source directory"
    if [ -d $BUILDDIR ]; then
        logmsg "--- removing previous source checkout"
        logcmd rm -rf $BUILDDIR
    fi
    logmsg "Checking out dtrace-provider from $REPO_NODEDTRACE"
    logcmd $GIT clone $REPO_NODEDTRACE $BUILDDIR
    if [ -n "$REV_NODEDTRACE" ]; then
        pushd $BUILDDIR > /dev/null
        logcmd $GIT checkout $REV_NODEDTRACE
        popd > /dev/null
    fi
    logmsg "Checking out libusdt from $REPO_LIBUSDT"
    pushd $BUILDDIR
    logcmd $GIT clone $REPO_LIBUSDT
    if [ -n "$REV_LIBUSDT" ]; then
        pushd libusdt > /dev/null
        logcmd $GIT checkout $REV_LIBUSDT
        popd > /dev/null
    fi
    popd > /dev/null
    popd > /dev/null
}

configure64() {
    logmsg "--- configure (64-bit)"
    LIBDIR=/opt/omni/lib/node \
    NODE_PATH=/opt/omni/lib/node \
    CXX="g++ -m64 -L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/node" \
    logcmd /opt/omni/bin/node-waf configure || \
        logerr "--- waf configure failed"
}

make_prog() {
    logmsg "--- make"
    logcmd /opt/omni/bin/node-waf build || \
        logerr "--- waf build failed"
}

make_install() {
    logmsg "--- make install"
    logcmd install -d ${DESTDIR}${PREFIX}/lib/node/ || \
         logerr "--- Failed to make install directory."
    DESTDIR=${DESTDIR} logcmd /opt/omni/bin/node-waf install || \
        logerr "--- waf install failed"
}

install_js() {
    # Install the JS portion of the module
    logcmd mkdir -p $DESTDIR/opt/omni/lib/node
    logcmd cp $TMPDIR/$BUILDDIR/dtrace-provider.js $DESTDIR/opt/omni/lib/node/ || \
        logerr "--- JS install failed"
}

init
download_git
patch_source
prep_build
build
make_isa_stub
install_js
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
