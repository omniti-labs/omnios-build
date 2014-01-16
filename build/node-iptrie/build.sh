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

PROG=node-iptrie
VER=git
PKG=omniti/runtime/nodejs/node-iptrie
SUMMARY="Patricia trees for node, specifically for IPv4 and IPv6 addresses."
DESC="$SUMMARY"

REPOS=http://github.com/postwait/node-iptrie
GIT=/usr/bin/git

BUILDARCH=64

PATH=/opt/omni/bin:$PATH
export PATH

BUILD_DEPENDS_IPS="developer/versioning/git network/rsync omniti/runtime/nodejs@0.10"
DEPENDS_IPS="omniti/runtime/nodejs@0.10"

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
    COMMIT=`$GIT log -1  --format=format:%h`
    REVDATE=`echo $REV | gawk '{ print strftime("%c %Z",$1) }'`
    VER=0.1.$REV
    VERHUMAN="${COMMIT:0:7} from $REVDATE"
    logmsg "Installing local node-gyp for build"
    logcmd /opt/omni/bin/npm install node-gyp || \
        logerr "node-gyp install failed"
    popd > /dev/null
    popd > /dev/null
}

# There is no configuration for this code, so just pretend we did it
configure64() {
    logmsg "--- node-gyp configure"
    logcmd ./node_modules/node-gyp/bin/node-gyp.js configure || \
        logerr "node-gyp configure failed"
}

make_prog() {
    logmsg "--- node-gyp build"
    MAKE=gmake \
    logcmd ./node_modules/node-gyp/bin/node-gyp.js build || \
        logerr "node-gyp build failed"
}
make_install() {
    logmsg "--- removing node-gyp"
    logcmd rm -rf ./node_modules
    logmsg "--- make install"
    logcmd install -d ${DESTDIR}${PREFIX}/lib/node/ || \
         logerr "--- Failed to make install directory."
    logcmd rsync -a --exclude=.git* . ${DESTDIR}${PREFIX}/lib/node/iptrie
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
