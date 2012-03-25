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

PROG=screen     # App name
VER=4.0.3       # App version
PVER=0.151002          # Package Version
PKG=terminal/screen      # Package name (without prefix)
SUMMARY="GNU Screen terminal multiplexer"
DESC="$SUMMARY"

gnu_cleanup() {
    logcmd rm -f $DESTDIR/usr/bin/{i386,amd64}/screen
    logcmd mv $DESTDIR/usr/bin/i386/screen-4.0.3 $DESTDIR/usr/bin/i386/screen
    logcmd mv $DESTDIR/usr/bin/amd64/screen-4.0.3 $DESTDIR/usr/bin/amd64/screen
    logcmd mv $DESTDIR/usr/man $DESTDIR/usr/share/
    logcmd mv $DESTDIR/usr/info $DESTDIR/usr/share/
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
gnu_cleanup
make_isa_stub
fix_permissions
make_package
clean_up
