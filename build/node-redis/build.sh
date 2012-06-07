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

PROG=node-redis
VER=0.5.11
PKG=omniti/runtime/nodejs/node-redis
TAG=v0.5.11
SUMMARY="redis client for node"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="developer/versioning/git omniti/runtime/nodejs"
DEPENDS_IPS="omniti/runtime/nodejs"

REPOS=http://github.com/mranney/node_redis
GIT=/usr/bin/git

BUILDARCH=32

PATH=/opt/omni/bin:$PATH
export PATH

download_git() {
    pushd $TMPDIR > /dev/null
    logmsg "Checking for source directory"
    if [ -d $BUILDDIR ]; then
        logmsg "--- removing previous source checkout"
        logcmd rm -rf $BUILDDIR
    fi
    logmsg "Checking code out from git repo"
    logcmd $GIT clone $REPOS.git $BUILDDIR || \
        logerr "--- failed to clone source"
    if [ -n "$TAG" ]; then
        cd $BUILDDIR
        git checkout $TAG
    fi
    popd > /dev/null
}

init
download_git
patch_source
prep_build

# We don't build anything.. just copy it over into the right location
logcmd mkdir -p $DESTDIR/opt/omni/lib/node
logcmd rm -rf $TMPDIR/$BUILDDIR/.git
logcmd cp -R $TMPDIR/$BUILDDIR/ $DESTDIR/opt/omni/lib/node/
logcmd mv $DESTDIR/opt/omni/lib/node/$PROG-$VER $DESTDIR/opt/omni/lib/node/redis

make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
