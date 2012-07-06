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
VER=2.4.0.1
PKG=omniti/runtime/nodejs/node-protobuf
SUMMARY="Protocol Buffers for Node.JS"
DESC="$SUMMARY"

REPOS=https://protobuf-for-node.googlecode.com/hg/ 
REV=5545aecd5e74
HG=/usr/bin/hg

BUILDARCH=64

PATH=/opt/omni/bin:$PATH
export PATH

BUILD_DEPENDS_IPS="developer/versioning/mercurial
                   omniti/library/protobuf
                   omniti/runtime/nodejs
                   system/library/g++-4-runtime
                   system/library/gcc-4-runtime
                   "
DEPENDS_IPS="omniti/library/protobuf
             omniti/runtime/nodejs
             system/library/g++-4-runtime
             system/library/gcc-4-runtime
             "

download_hg() {
    pushd $TMPDIR > /dev/null
    logmsg "Checking for source directory"
    if [ -d $BUILDDIR ]; then
        logmsg "--- removing previous source checkout"
        logcmd rm -rf $BUILDDIR
    fi
    logmsg "Checking code out from hg repo"
    logcmd $HG clone $REPOS $BUILDDIR
    (cd $BUILDDIR && logcmd $HG checkout 5545aecd5e74)
    popd > /dev/null
}

configure64() {
    logmsg "--- configure (64-bit)"
    PROTOBUF=/opt/omni LIBDIR=/opt/omni/lib/node \
    NODE_PATH=/opt/omni/lib/node \
    CXX="g++ -m64 -L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/node" \
    CXXFLAGS="-DICONV_SRC_CONST=const -I/opt/omni/include -I/opt/omni/include/node/uv-private -fpermissive" \
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

init
download_hg
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
