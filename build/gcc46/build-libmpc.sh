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

PROG=mpc         # App name
VER=0.8.2        # App version
VERHUMAN=$VER    # Human-readable version
PVER=1           # Package Version (numeric only)
PKG=developer/gcc46/libmpc-gcc46 # Package name (without prefix)
SUMMARY="gcc46 - private libmpc"
DESC="$SUMMARY" # Longer description

DEPENDS_IPS="developer/gcc46/libgmp-gcc46 developer/gcc46/libmpfr-gcc46"

# This stuff is in its own domain
PKGPREFIX=""

[[ "$BUILDARCH" == "both" ]] && BUILDARCH=32
PREFIX=/opt/gcc-4.6.2
CC=gcc
CONFIGURE_OPTS="--with-gmp=/opt/gcc-4.6.2 --with-mpfr=/opt/gcc-4.6.2"

make_install32() {
    make_install
    logcmd rm -rf $DESTDIR/opt/gcc-4.6.2/share/info
}

reset_configure_opts
init
download_source $PROG $PROG $VER
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up
