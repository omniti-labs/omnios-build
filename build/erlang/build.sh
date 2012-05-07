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

PROG=erlang
OTPVER=R14B04
REPO=git://github.com/slfritchie/otp.git
VER=14.0.4
VERHUMAN=$VER
PKG=omniti/runtime/erlang
SUMMARY="Erlang OTP Platform"
DESC="$SUMMARY ($OTPVER)"

TAR=gtar
BUILDDIR=otp_src_$OTPVER
ERL_TOP=$TMPDIR/$BUILDDIR
export ERL_TOP

BUILDARCH=64
BUILD_DEPENDS_IPS="archiver/gnu-tar perl developer/versioning/git"
DEPENDS_IPS="library/security/openssl developer/dtrace
    system/library system/library/math"
NO_PARALLEL_MAKE=1

CONFIGURE_OPTS32="--prefix=$PREFIX"
CONFIGURE_OPTS="--enable-smp-support
    --enable-dtrace
    --enable-threads
    --with-ssl=/usr
    --enable-dynamic-ssl-lib
    --enable-m64-build"

clone_source() {
  pushd $TMPDIR > /dev/null || logerr "Cannot cd to $TMPDIR"
  logmsg "--- Cloning from $REPO"
  logcmd git clone $REPO $BUILDDIR
  pushd $BUILDDIR > /dev/null || logerr "Cannot cd to $BUILDDIR"
  logcmd git pull || logerr "Could not pull -- something wrong with checkout"
  logcmd git reset --hard HEAD || logerr "Couldn't reset checkout to HEAD"
  logmsg " --- pulling dtrace bits"
  logcmd git checkout dtrace-r14b04 || logerr "Could not pull dtrace bits"
  logcmd ./otp_build autoconf || logerr "autoconf failed"
  popd > /dev/null
  popd > /dev/null
}

init
if [[ -z "$REPO" ]]; then
  download_source $PROG $PROG $VER
else
  clone_source
fi
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
