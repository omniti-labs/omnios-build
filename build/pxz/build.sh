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

PROG=pxz
VER=git  # The real version is set in download_git()
PKG=omniti/compress/pxz
SUMMARY="Parallel LZMA compressor using liblzma"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="compress/xz developer/versioning/git"
# We require libgomp which only comes with the compiler package
DEPENDS_IPS="compress/xz developer/gcc46 system/library/gcc-4-runtime"

GIT=/usr/bin/git
REPO_PXZ=git://github.com/jnovy/pxz.git
BUILDARCH=64

download_git() {
    REPOS=$1
    BUILDDIR=$2
    REV=$3
    # Create TMPDIR if it doesn't exist
    if [[ ! -d $TMPDIR ]]; then
        logmsg "Specified temp directory $TMPDIR does not exist.  Creating it now."
        logcmd mkdir -p $TMPDIR
    fi
    pushd $TMPDIR > /dev/null
    logmsg "Checking for source directory"
    if [ -d $BUILDDIR ]; then
        logmsg "Removing source directory"
        rm -rf $BUILDDIR
    fi
    if [ ! -d $BUILDDIR ]; then
        logmsg "Checking code out from $REPOS"
        logcmd $GIT clone $REPOS $BUILDDIR
    fi
    pushd $BUILDDIR > /dev/null
    $GIT pull
    if [ -n $REV ]; then $GIT checkout $REV; fi
    REV=`$GIT log -1  --format=format:%at`
    VER="0.1.$REV"
    REVDATE=`echo $REV | gawk '{ print strftime("%c %Z",$1) }'`
    VERHUMAN="checkout from $REVDATE"
    popd > /dev/null
    popd > /dev/null
}

configure64() {
    export PREFIX
    export DESTDIR
    export BINDIR=$PREFIX/bin/$ISAPART64
    export MANDIR=$PREFIX/share/man
    export CPPFLAGS="-I/usr/include/ast"
    export CFLAGS="$CFLAGS $CFLAGS64 -nodefaultlibs -nostdlib"
    export LDFLAGS="$LDFLAGS $LDFLAGS64 /opt/gcc-4.6.3/lib/$ISAPART64/libgomp.a /usr/lib/$ISAPART64/libast.so.1 -lc -lsocket -lm -lgcc_s -lnsl -lmp -lmd"
    export CC=$CC
}

init
download_git $REPO_PXZ $PROG-git
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
