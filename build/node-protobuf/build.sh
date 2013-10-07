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

PROG=node-protobuf
VER=2.4.1.0.8.7
PKG=omniti/runtime/nodejs/node-protobuf
SUMMARY="Protocol Buffers for Node.JS"
DESC="$SUMMARY"

REPOS=https://github.com/chrisdew/protobuf.git
REV=
GIT=/usr/bin/git

BUILDARCH=64

PATH=/opt/omni/bin:$PATH
export PATH

BUILD_DEPENDS_IPS="omniti/library/protobuf
                   omniti/runtime/nodejs
                   system/library/g++-4-runtime
                   system/library/gcc-4-runtime
                   "
DEPENDS_IPS="omniti/library/protobuf
             omniti/runtime/nodejs
             system/library/g++-4-runtime
             system/library/gcc-4-runtime
             "

download_git() {
    pushd $TMPDIR > /dev/null
    logmsg "Checking for source directory"
    if [ -d $BUILDDIR ]; then
        logmsg "--- removing previous source checkout"
        logcmd rm -rf $BUILDDIR
    fi
    logmsg "Checking code out from git repo"
    logcmd $GIT clone $REPOS $BUILDDIR
    pushd $BUILDDIR > /dev/null
    if [ -n "$REV" ]; then
        logcmd $GIT checkout $REV
    fi
    REV=`$GIT log -1  --format=format:%at`
    REVDATE=`echo $REV | gawk '{ print strftime("%c %Z",$1) }'`
    #VER=0.1.$REV
    VERHUMAN="checkout from $REV"
    popd > /dev/null
    popd > /dev/null
}

configure64() {
    logmsg "--- configure"
}

make_prog() {
    logmsg "--- make"
    MAKE=gmake \
    logcmd /opt/omni/bin/npm install . || \
        logerr "--- npm build failed"
}

make_install() {
    logmsg "--- make install"
    logcmd install -d ${DESTDIR}${PREFIX}/lib/node/ || \
         logerr "--- Failed to make install directory."
    logcmd install -m 0555 build/Release/protobuf_for_node.node \
        ${DESTDIR}${PREFIX}/lib/node/protobuf_for_node.node || \
         logerr "--- Failed to install module."
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
