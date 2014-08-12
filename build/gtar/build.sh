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

PROG=tar
VER=1.28
PKG=archiver/gnu-tar
SUMMARY="gtar - GNU tar"
DESC="GNU tar - A utility used to store, backup, and transport files (gtar) $VER"

BUILDARCH=32
# GNU tar doesn't like to be configured by root.  This var ignores those errors
export FORCE_UNSAFE_CONFIGURE=1

CONFIGURE_OPTS="--program-prefix=g --with-rmt=/usr/sbin/rmt"
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --bindir=/usr/bin"

make_sym_links() {
    logmsg "Creating necessary symlinks"
    logmsg "--- usr/sfw/bin/gtar"
    logcmd mkdir -p $DESTDIR/usr/sfw/bin
    pushd $DESTDIR/usr/sfw/bin > /dev/null
    logcmd ln -s ../../bin/gtar gtar || \
            logerr "Failed to create link for usr/sfw/bin/gtar"
    popd > /dev/null
    logmsg "--- usr/gnu/bin/tar"
    logcmd mkdir -p $DESTDIR/usr/gnu/bin
    pushd $DESTDIR/usr/gnu/bin > /dev/null
    logcmd ln -s ../../bin/gtar tar || \
            logerr "Failed to create link for usr/bin/gtar"
    popd > /dev/null
}


init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_sym_links
make_package
clean_up
