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

PROG=inspircd   # App name
VER=2.0.14      # App version
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=omniti/network/inspircd            # Package name (e.g. library/foo)
SUMMARY="IRC Daemon"      # One-liner, must be filled in
DESC="InspIRCd is a modular Internet Relay Chat (IRC) server written in C++ for Linux, BSD, Windows and Mac OS X systems which was created from scratch to be stable, modern and lightweight."         # Longer description, must be filled in

TAR=gtar
DEPENDS_IPS="library/gnutls system/library/security/libgcrypt omniti/network/openldap-client"
BUILD_DEPENDS_IPS="archiver/gnu-tar omniti/library/pkgconf $DEPENDS_IPS"

PREFIX="/opt/$PROG"

BUILDARCH=32

# For openldap libs
#CXXFLAGS="-I/opt/omni/include"
#LDFLAGS32="-L/opt/omni/lib"
#LDFLAGS64="-L/opt/omni/lib/$ISAPART64"

EXTRA_MODULES="
    m_ldapauth.cpp
    m_ldapoper.cpp
"

CONFIGURE_OPTS="--enable-gnutls"
CONFIGURE_OPTS_32="--prefix=$PREFIX
    --binary-dir=$PREFIX/bin/$ISAPART"

CONFIGURE_OPTS_64="--prefix=$PREFIX
    --binary-dir=$PREFIX/bin/$ISAPART64
    --library-dir=$PREFIX/lib/$ISAPART64
    --module-dir=$PREFIX/modules/$ISAPART64"

save_function build build_orig
build() {
    logmsg "Enabling modules"
    for m in $EXTRA_MODULES; do
        logmsg "--- $m"
        logcmd ln -s extra/$m $TMPDIR/$BUILDDIR/src/modules
    done
    build_orig
}

# Set pkg-config path appropriately
save_function build32 build32_orig
build32() {
    export PKG_CONFIG_PATH=/usr/lib/pkgconfig
    build32_orig
}

save_function build64 build64_orig
build64() {
    export PKG_CONFIG_PATH=/usr/lib/$ISAPART64/pkgconfig
    build64_orig
}


init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
