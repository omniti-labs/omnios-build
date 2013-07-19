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
# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=iftop      # App name
VERHUMAN=1.0pre2 # Human-readable version
VER=${VERHUMAN/pre/.} # App version
BUILDDIR=$PROG-$VERHUMAN
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=network/iftop # Package name (e.g. library/foo)
SUMMARY="display bandwidth usage on an interface"
DESC="$SUMMARY"   # Longer description, must be filled in

BUILD_DEPENDS_IPS="system/library/pcap library/ncurses"
AUTO_DEPENDS=1

CFLAGS="-g"
LDFLAGS32="-L/usr/gnu/lib -R/usr/gnu/lib"
LDFLAGS64="-L/usr/gnu/lib/$ISAPART64 -R/usr/gnu/lib/$ISAPART64"

init
download_source $PROG $PROG $VERHUMAN
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
