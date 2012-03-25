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

PROG=make       # App name
VER=3.82        # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=developer/build/gnu-make  # Package name (without prefix)
SUMMARY="gmake - GNU make"
DESC="GNU make - A utility used to build software (gmake) $VER"

BUILDARCH=32
CONFIGURE_OPTS="--bindir=$PREFIX/bin --program-prefix=g"

make_sym_links() {
    logmsg "Creating necessary symlinks"
    logmsg "--- usr/sfw/bin/gmake"
    logcmd mkdir -p $DESTDIR/usr/sfw/bin
    pushd $DESTDIR/usr/sfw/bin > /dev/null
    logcmd ln -s ../../bin/gmake gmake || \
            logerr "Failed to create link for usr/sfw/bin/gmake"
    popd > /dev/null
    logmsg "--- usr/gnu/bin/make"
    logcmd mkdir -p $DESTDIR/usr/gnu/bin
    pushd $DESTDIR/usr/gnu/bin > /dev/null
    logcmd ln -s ../../bin/gmake make || \
            logerr "Failed to create link for usr/gnu/bin/make"
    popd > /dev/null
    logmsg "--- usr/sfw/share/man/man1/gmake.1"
    logcmd mkdir -p $DESTDIR/usr/sfw/share/man/man1
    pushd $DESTDIR/usr/sfw/share/man/man1 > /dev/null
    logcmd ln -s ../../../../share/man/man1/gmake.1 gmake.1 || \
            logerr "Failed to create link for usr/sfw/share/man/man1/gmake.1"
    popd > /dev/null
    logmsg "--- usr/gnu/share/man/man1/make.1"
    logcmd mkdir -p $DESTDIR/usr/gnu/share/man/man1
    pushd $DESTDIR/usr/gnu/share/man/man1 > /dev/null
    logcmd ln -s ../../../../share/man/man1/gmake.1 make.1 || \
            logerr "Failed to create link for usr/gnu/share/man/man1/make.1"
    popd > /dev/null
}


init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_sym_links
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
