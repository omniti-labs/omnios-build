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

PROG=node-libdtrace
VER=0.0.3.1
PKG=omniti/runtime/nodejs/node-libdtrace
SUMMARY="Solaris libdtrace bindings"
DESC="$SUMMARY"

REPOS="https://github.com/bcantrill/node-libdtrace.git"
REV="b81b934275b733b5aabff42d6b72f5978b512629"
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
    logmsg "Checking code out from git repo"
    logcmd $GIT clone $REPOS $BUILDDIR
    pushd $BUILDDIR > /dev/null
    if [ -n "$REV" ]; then
        logcmd $GIT checkout $REV
    fi
    REV=`$GIT log -1  --format=format:%at`
    COMMIT=`$GIT log -1  --format=format:%h`
    REVDATE=`echo $REV | gawk '{ print strftime("%c %Z",$1) }'`
    VERHUMAN="${COMMIT:0:7} from $REVDATE"
    popd > /dev/null
    popd > /dev/null
}

configure64() {
    logmsg "--- configure"
}

make_prog() {
    logmsg "--- make"
    MAKE=gmake \
    logcmd /opt/omni/bin/npm build . || \
        logerr "--- npm build failed"
    logcmd /opt/omni/bin/npm install bindings || \
        logerr "--- failed to install bindings"
}

make_install() {
    logmsg "--- make install"
    logcmd install -d ${DESTDIR}${PREFIX}/lib/node/ || \
         logerr "--- Failed to make install directory."
    logcmd rsync -a --exclude=.git* . ${DESTDIR}${PREFIX}/lib/node/libdtrace/ || \
         logerr "--- Failed to install module."
}

init
download_git
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
