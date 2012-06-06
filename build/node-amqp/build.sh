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

PROG=node-amqp # App name
VER=0.0.5      # App version
PKG=omniti/runtime/nodejs/node-amqp
TAG=741628e8e182f174745803c688a230b9da9e5448
SUMMARY="AMQP client for nodejs"
DESC="$SUMMARY"

DEPENDS_IPS="omniti/runtime/nodejs"
BUILD_DEPENDS_IPS="developer/versioning/git network/rsync"

REPOS=http://github.com/postwait/node-amqp
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
    logcmd $GIT clone $REPOS.git $BUILDDIR
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
mkdir -p $DESTDIR/opt/omni/lib/node
rsync -a --exclude=.git\* $TMPDIR/$BUILDDIR/ $DESTDIR/opt/omni/lib/node/
mv $DESTDIR/opt/omni/lib/node/amqp.js $DESTDIR/opt/omni/lib/node/amqp

make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
