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

# We have to build as root to manipulate ZFS datasets
export ROOT_OK=yes

# Load support functions
. ../../lib/functions.sh

if [[ "$UID" != "0" ]]; then
    logerr "--- This script needs to be run as root."
fi

# We also need to be in the global zone to access the kernel binary
if [[ `zonename` != "global" ]]; then
    logerr "--- This script must be run in the global zone."
fi

PROG=kayak
VER=1.0
VERHUMAN=$VER
PKG=system/install/kayak
SUMMARY="Kayak - network installer (server files)"
DESC="Kayak is the network installer for OmniOS, using PXE, DHCP and HTTP"

BUILD_DEPENDS_IPS="developer/versioning/git"
DEPENDS_IPS="developer/build/gnu-make developer/dtrace service/network/tftp"

GIT=/usr/bin/git
CHECKOUTDIR=$TMPDIR/$BUILDDIR
IMG_DSET=rpool/kayak_image

clone_source() {
    logmsg "kayak -> $CHECKOUTDIR/kayak"
    logcmd mkdir -p $TMPDIR/$BUILDDIR
    pushd $CHECKOUTDIR > /dev/null
    if [[ ! -d kayak ]]; then
        logmsg "--- No checkout found, cloning anew"
        logcmd $GIT clone anon@src.omniti.com:~omnios/core/kayak
    else
        logmsg "--- Checkout found, updating it"
        pushd kayak > /dev/null
        $GIT pull || logerr "failed to update"
        popd > /dev/null
    fi
    popd > /dev/null
}

build_server() {
    pushd $CHECKOUTDIR/kayak > /dev/null || logerr "Cannot change to src dir"
    logmsg "Installing server files"
    logcmd gmake DESTDIR=$DESTDIR install-package || \
        logerr "gmake failed"
    popd > /dev/null
}

build_miniroot() {
    if [[ -z "`zfs list $IMG_DSET`" ]]; then
        /sbin/zfs create $IMG_DSET
    fi
    pushd $CHECKOUTDIR/kayak > /dev/null || logerr "Cannot change to src dir"
    logmsg "Building miniroot"
    logcmd gmake BUILDSEND=$IMG_DSET DESTDIR=$DESTDIR install-tftp || \
        logerr "gmake failed"

    popd > /dev/null
}

init
clone_source
prep_build
logmsg "Now building $PKG"
build_server
make_package
clean_up

PKG=system/install/kayak-kernel
SUMMARY="Kayak - network installer (kernel, miniroot and pxegrub)"
PKGE=$(url_encode $PKG)
PKGD=${PKGE//%/_}
DESTDIR=$DTMPDIR/${PKGD}_pkg
DEPENDS_IPS=""

logmsg "Now building $PKG"
build_miniroot
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
