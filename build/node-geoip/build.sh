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

PROG=node-geoip  # App name
VER=git
PKG=omniti/runtime/nodejs/node-geoip
SUMMARY="Naive wrapper around libGeoIP for use with node.js"
DESC="$SUMMARY"

REPOS=http://github.com/postwait/node-geoip
GIT=/usr/bin/git

BUILDARCH=64

PATH=/opt/omni/bin:$PATH
export PATH

BUILD_DEPENDS_IPS="developer/versioning/git omniti/library/geoip omniti/library/libiconv omniti/runtime/nodejs"
DEPENDS_IPS="omniti/runtime/nodejs omniti/library/geoip omniti/library/libiconv"

download_git() {
    pushd $TMPDIR > /dev/null
    logmsg "Checking for source directory"
    if [ -d $BUILDDIR ]; then
        logmsg "--- removing previous source checkout"
        logcmd rm -rf $BUILDDIR
    fi
    logmsg "Checking code out from git repo"
    logcmd $GIT clone $REPOS.git $BUILDDIR
    pushd $BUILDDIR > /dev/null
    REV=`$GIT log -1  --format=format:%at`
    REVDATE=`echo $REV | gawk '{ print strftime("%c %Z",$1) }'`
    VER=0.1.$REV
    VERHUMAN="checkout from $REVDATE"
    popd > /dev/null
    popd > /dev/null
}

# There is no configuration for this code, so just pretend we did it
configure64() {
    true
}

make_prog() {
    logmsg "--- make node-geoip"
    CXX="g++ -m64 -L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64" \
    CXXFLAGS="-DICONV_SRC_CONST=const -I/opt/omni/include" \
    logcmd /opt/omni/bin/node-waf configure build || \
        logerr "------ make failed"
}

make_install() {
    logmsg "--- make install"
    logcmd install -d ${DESTDIR}${PREFIX}/lib/node/geoip || \
         logerr "--- Failed to make install directory."
    cp -r . ${DESTDIR}${PREFIX}/lib/node/geoip/
    rm -rf ${DESTDIR}${PREFIX}/lib/node/geoip/.git
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
