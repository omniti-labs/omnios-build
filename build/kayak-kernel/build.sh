#!/usr/bin/bash
#
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#

#
# Copyright 2017 OmniTI Computer Consulting, Inc.  All rights reserved.
#

# We have to build as root to manipulate ZFS datasets
export ROOT_OK=yes

KAYAK_CLOBBER=${KAYAK_CLOBBER:=0}

# Load support functions
. ../../lib/functions.sh

# Reality check.
if [[ "$UID" == 0 ]]; then
    SUDO=""
    OLDUSER=root
elif [[ ! -z $KAYAK_SUDO_BUILD ]]; then
    SUDO="sudo -n"
    OLDUSER=`whoami`
else
    logerr "--- You must be root or set KAYAK_SUDO_BUILD and have no-password sudo enabled"
    logmsg "Proceeding as if KAYAK_SUDO_BUILD was set to 1."
    KAYAK_SUDO_BUILD=1
    SUDO="sudo -n"
    OLDUSER=`whoami`
fi

# Explicitly figure out BATCH so the sudo-bits can honor it.
if [[ ${BATCH} == 1 ]]; then
    BATCHMODE=1
else
    BATCHMODE=0
fi

# Set up VERSION now in the environment for Kayak's makefiles if needed.
# NOTE: This is currently dependent on PREBUILT_ILLUMOS as a way to prevent
# least-surprise.  We may want to promote this to "do it all the time!"
if [ -d ${PREBUILT_ILLUMOS:-/dev/null} ]; then
    logmsg "Using pre-built Illumos at $PREBUILT_ILLUMOS (may need to wait)"
    wait_for_prebuilt
    export VERSION=r$RELVER
    logmsg "Using VERSION=$VERSION"
else
    logmsg "Using non-pre-built illumos - unsetting VERSION."
    unset VERSION
    PREBUILT_ILLUMOS="/dev/null"
fi

# We also need to be in the global zone to access the kernel binary
if [[ `zonename` != "global" ]]; then
    logerr "--- This script must be run in the global zone."
fi

VER=1.1
GIT=/usr/bin/git
CHECKOUTDIR=$TMPDIR/$BUILDDIR
IMG_DSET=rpool/kayak_image
# NOTE: If PKGURL is specified, allow it to be different than the destination
# PKGSRVR.  PKGURL is from where kayak-kernel takes its bits. PKGSRVR is where
# this package (with a prebuilt miniroot and unix) will be installed.
PKGURL=${PKGURL:=$PKGSRVR}
export PKGURL
logmsg "Grabbing packages from $PKGURL."
logmsg "Publishing kayak-kernel to $PKGSRVR."

clone_source() {
    logmsg "kayak -> $CHECKOUTDIR/kayak"
    logcmd mkdir -p $TMPDIR/$BUILDDIR
    pushd $CHECKOUTDIR > /dev/null
    if [[ -d kayak ]]; then
        logmsg "--- old checkout found, removing it."
        logcmd rm -rf kayak
    fi
    logcmd $GIT clone https://github.com/omniti-labs/kayak
    pushd kayak > /dev/null
    logcmd $GIT checkout r$RELVER || logmsg "No r$RELVER branch, using master."
    GITREV=`$GIT log -1  --format=format:%at`
    COMMIT=`$GIT log -1  --format=format:%h`
    REVDATE=`echo $GITREV | gawk '{ print strftime("%c %Z",$1) }'`
    VERHUMAN="${COMMIT:0:7} from $REVDATE"
    popd > /dev/null
    popd > /dev/null
}

PKG=system/install/kayak-kernel
SUMMARY="Kayak - network installer media (kernel, miniroot, pxegrub, and pxeboot)"
PKGE=$(url_encode $PKG)
PKGD=${PKGE//%/_}
DESTDIR=$DTMPDIR/${PKGD}_pkg
DEPENDS_IPS=""

clone_source
logmsg "Now building $PKG"
$SUDO ./sudo-bits.sh $KAYAK_CLOBBER $IMG_DSET $CHECKOUTDIR $PREBUILT_ILLUMOS \
    $DESTDIR $PKGURL $VER $OLDUSER $BATCHMODE
if [[ $? != 0 ]]; then
    logerr "--- sudo-bits sub-script failed."
fi
make_package kayak-kernel.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
