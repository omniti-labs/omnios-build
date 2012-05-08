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

PROG=node
VER=0.6.17
GITREPO=https://github.com/joyent/node.git
GITHASH=4ced23deaf36493f4303a18f6fdce768c58becc0
VERHUMAN=$VER
PKG=omniti/runtime/nodejs
SUMMARY="node.js"
DESC="$SUMMARY ($VER)"

BUILD_DEPENDS_IPS="developer/versioning/git runtime/python-26"
DEPENDS_IPS="library/security/openssl library/zlib runtime/python-26
	shell/bash system/library/g++-4-runtime system/library/gcc-4-runtime
	system/library/math system/library"
GIT=git
MAKE=gmake
BUILDARCH=64
CFLAGS="-m64"
export CFLAGS
CONFIGURE_OPTS="--shared-zlib --prefix=/opt/omni"
CONFIGURE_OPTS_64="--dest-cpu=x64"

clone_source(){
    logmsg "Creating build dir $TMPDIR"
    logcmd mkdir $TMPDIR
    logmsg "Entering $TMPDIR"
    pushd $TMPDIR > /dev/null 
    logmsg "Cloning into workspace"
    logcmd $GIT clone $GITREPO $BUILDDIR
    pushd $BUILDDIR > /dev/null
    logmsg "Setting checkout to $GITHASH"
    logcmd $GIT checkout $GITHASH
    logcmd $GIT reset --hard $GITHASH
    popd > /dev/null 
    logmsg "Leaving $TMPDIR/$BUILDDIR"
    popd > /dev/null 
}

init
clone_source
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
