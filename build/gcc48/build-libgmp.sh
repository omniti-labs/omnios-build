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

GCCVER=4.8.1
PATH=/opt/gcc-${GCCVER}/bin:$PATH
export LD_LIBRARY_PATH=/opt/gcc-${GCCVER}/lib

PROG=gmp         # App name
VER=5.0.5        # App version
VERHUMAN=$VER    # Human-readable version
PKG=developer/gcc48/libgmp-gcc48 # Package name (without prefix)
SUMMARY="gcc48 - private libgmp"
DESC="$SUMMARY" # Longer description

# This stuff is in its own domain
PKGPREFIX=""

[[ "$BUILDARCH" == "both" ]] && BUILDARCH=32
PREFIX=/opt/gcc-${GCCVER}
CC=gcc
# '--disable-assembly' fixes http://omnios.omniti.com/ticket.php/83
CONFIGURE_OPTS="--enable-cxx --disable-assembly"
CFLAGS="-fexceptions"
ABI=32
export ABI

make_install32() {
    logcmd mkdir -p $DESTDIR/opt/gcc-${GCCVER}/share/info
    make_install
    logcmd rm -rf $DESTDIR/opt/gcc-${GCCVER}/share/info
}

reset_configure_opts
init
download_source $PROG $PROG $VER
prep_build
build
make_isa_stub
make_package libgmp.mog
clean_up
