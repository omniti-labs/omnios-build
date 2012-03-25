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

PROG=m4         # App name
VER=1.4.16      # App version
PVER=2          # Package Version
PKG=developer/macro/gnu-m4  # Package name (without prefix)
SUMMARY="GNU m4"
DESC="GNU m4 - A macro processor (gm4)"

PREFIX=/usr/gnu
reset_configure_opts

BUILDARCH=32
CONFIGURE_OPTS="--infodir=/usr/share/info"

make_sym_links() {
    logmsg "Creating various symlinks"
    logmsg "--- usr/sfw/bin/gm4"
    logcmd mkdir -p $DESTDIR/usr/sfw/bin
    pushd $DESTDIR/usr/sfw/bin > /dev/null
    logcmd ln -s ../../gnu/bin/m4 gm4 || \
            logerr "Failed to create link for usr/sfw/bin/gm4"
    popd > /dev/null
    logmsg "--- usr/bin/gm4"
    logcmd mkdir -p $DESTDIR/usr/bin
    pushd $DESTDIR/usr/bin > /dev/null
    logcmd ln -s ../gnu/bin/m4 gm4 || \
            logerr "Failed to create link for usr/bin/gm4"
    popd > /dev/null
    logmsg "--- usr/share/man/man1/gm4.1"
    logcmd mkdir -p $DESTDIR/usr/share/man/man1
    pushd $DESTDIR/usr/share/man/man1 > /dev/null
    logcmd ln -s ../../../gnu/share/man/man1/m4.1 gm4.1 || \
            logerr "Failed to create link for usr/share/man/man1/gm4.1"
    popd > /dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_sym_links
fix_permissions
make_package
clean_up
