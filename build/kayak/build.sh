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

if [[ "$UID" != 0 && ! -z $KAYAK_SUDO_BUILD ]]; then
       # Run sudo BEFORE functions.sh eats the parameters.
       # Installing OmniOS-on-demand should create an entry in /etc/sudoers.d/
       # to cover running this script under sudo.
       echo "Running again under sudo, currently UID = $UID, EUID = $EUID."
       export OLDUSER=`whoami`
       export KAYAK_SUDO_BUILD
       exec sudo -n ./build.sh $@
fi

# Load support functions
. ../../lib/functions.sh

# Set up VERSION now in the environment for Kayak's makefiles if needed.
# NOTE: This is currently dependent on PREBUILT_ILLUMOS as a way to prevent
# least-surprise.  We may want to promote this to "do it all the time!"
if [ -d ${PREBUILT_ILLUMOS:-/dev/null} ]; then
    logmsg "Using pre-built Illumos at $PREBUILT_ILLUMOS (may need to wait)"
    wait_for_prebuilt
    # Export PREBUILT_ILLUMOS for kayak's scripts.
    export PREBUILT_ILLUMOS
    export VERSION=r$RELVER
    logmsg "Using VERSION=$VERSION"
else
    logmsg "Using non-pre-built illumos - unsetting VERSION."
    unset VERSION
fi

if [[ "$UID" != "0" ]]; then
    logerr "--- This script needs to be run as root."
fi

# We also need to be in the global zone to access the kernel binary
if [[ `zonename` != "global" ]]; then
    logerr "--- This script must be run in the global zone."
fi

PROG=kayak
VER=1.1
VERHUMAN=$VER
PKG=system/install/kayak
SUMMARY="Kayak - network installer (server files)"
DESC="Kayak is the network installer for OmniOS, using PXE, DHCP and HTTP"

BUILD_DEPENDS_IPS="developer/versioning/git"
DEPENDS_IPS="developer/build/gnu-make developer/dtrace service/network/tftp"

GIT=/usr/bin/git
CHECKOUTDIR=$TMPDIR/$BUILDDIR
IMG_DSET=rpool/kayak_image
PKGURL=$PKGSRVR
export PKGURL

clone_source() {
    logmsg "kayak -> $CHECKOUTDIR/kayak"
    logcmd mkdir -p $TMPDIR/$BUILDDIR
    pushd $CHECKOUTDIR > /dev/null
    if [[ -d kayak ]]; then
        logmsg "--- old checkout found, removing it."
        logcmd rm -rf kayak
    fi
    logcmd $GIT clone anon@src.omniti.com:~omnios/core/kayak
    pushd kayak > /dev/null
    logcmd $GIT checkout r$RELVER || logmsg "No r$RELVER branch, using master."
    GITREV=`$GIT log -1  --format=format:%at`
    COMMIT=`$GIT log -1  --format=format:%h`
    REVDATE=`echo $GITREV | gawk '{ print strftime("%c %Z",$1) }'`
    VERHUMAN="${COMMIT:0:7} from $REVDATE"
    popd > /dev/null
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
make_package kayak.mog
clean_up
# Do extra cleaning up if we got run under sudo from ourselves.
if [[ -z `echo $RPATH | grep http://` ]]; then
       OLDUSER=`ls -ltd $RPATH | awk '{print $3}'`
       logmsg "--- Re-chowning $RPATH to user $OLDUSER"
       logcmd chown -R $OLDUSER $RPATH
fi

PKG=system/install/kayak-kernel
SUMMARY="Kayak - network installer (kernel, miniroot and pxegrub)"
PKGE=$(url_encode $PKG)
PKGD=${PKGE//%/_}
DESTDIR=$DTMPDIR/${PKGD}_pkg
DEPENDS_IPS=""

logmsg "Now building $PKG"
build_miniroot
make_package kayak-kernel.mog
clean_up
# Do extra cleaning up if we got run under sudo from ourselves.
if [[ -z `echo $RPATH | grep http://` ]]; then
       OLDUSER=`ls -ltd $RPATH | awk '{print $3}'`
       logmsg "--- Re-chowning $RPATH to user $OLDUSER"
       logcmd chown -R $OLDUSER $RPATH
fi

# Vim hints
# vim:ts=4:sw=4:et:
