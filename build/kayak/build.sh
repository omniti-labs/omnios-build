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

# Load support functions
. ../../lib/functions.sh

PROG=kayak
VER=1.1
VERHUMAN=$VER
PKG=system/install/kayak
SUMMARY="Kayak - OmniOS media generator and server"
DESC="Kayak generates install media for OmniOS: either ISO/USB or network installation using PXE, DHCP, and HTTP"

BUILD_DEPENDS_IPS="developer/versioning/git"
DEPENDS_IPS="developer/build/gnu-make developer/dtrace service/network/tftp"

GIT=/usr/bin/git
CHECKOUTDIR=$TMPDIR/$BUILDDIR

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

build_server() {
    pushd $CHECKOUTDIR/kayak > /dev/null || logerr "Cannot change to src dir"
    logmsg "Installing server files"
    logcmd gmake DESTDIR=$DESTDIR install-package || \
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

# Vim hints
# vim:ts=4:sw=4:et:
