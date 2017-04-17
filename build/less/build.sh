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
# Copyright 2017 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=less       # App name
VER=487         # App version
PKG=text/less    # Package name (without prefix)
SUMMARY="$PROG - GNU paginator"
DESC="$SUMMARY"

DEPENDS_IPS="SUNWcs"

BUILDARCH=32
CONFIGURE_OPTS_32="--prefix=$PREFIX
        --sysconfdir=/etc
        --includedir=$PREFIX/include
        --bindir=$PREFIX/bin
        --sbindir=$PREFIX/sbin
        --libdir=$PREFIX/lib
        --libexecdir=$PREFIX/libexec"

install_license() {
    local LICENSE_FILE
    LICENSE_FILE=$TMPDIR/$BUILDDIR/$1

    if [ -f "$LICENSE_FILE" ]; then
        logmsg "Using $LICENSE_FILE as package license"
        logcmd cp $LICENSE_FILE $DESTDIR/license
    else
        logerr "-- $LICENSE_FILE not found!"
        exit 255
    fi
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
install_license COPYING
make_isa_stub
strip_install
make_package
clean_up
