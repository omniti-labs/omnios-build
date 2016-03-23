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

PROG=gmp
VER=6.1.0
VERHUMAN=$VER
PKG=library/gmp
SUMMARY="GNU MP $VER"
DESC="The GNU Multiple Precision (Bignum) Library ($VER)"

# Cribbed from upstream, used to set MPN_PATH during configure
MPN32="x86/pentium x86 generic"
MPN64="x86_64/pentium4 x86_64 generic"
export MPN32 MPN64

BUILD_DEPENDS_IPS=developer/build/libtool

CFLAGS="-fexceptions"
CONFIGURE_OPTS="--includedir=/usr/include/gmp 
                --localstatedir=/var 
                --enable-shared 
                --disable-static
                --disable-libtool-lock
                --disable-alloca
                --enable-cxx
                --enable-fft
                --enable-mpbsd
                --disable-fat
                --with-pic"

configure32() {
    logmsg "--- configure (32-bit)"
    logcmd cp /usr/share/libtool/config/config.guess $TMPDIR/$BUILDDIR
    CFLAGS="$CFLAGS $CFLAGS32" \
    CXXFLAGS="$CXXFLAGS $CXXFLAGS32" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS32" \
    LDFLAGS="$LDFLAGS $LDFLAGS32" \
    CC=$CC CXX=$CXX \
    ABI=32 \
    MPN_PATH="$MPN32" \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_32 \
    $CONFIGURE_OPTS || \
        logerr "--- Configure failed"
}

configure64() {
    logmsg "--- configure (64-bit)"
    logcmd cp /usr/share/libtool/config/config.guess $TMPDIR/$BUILDDIR
    CFLAGS="$CFLAGS $CFLAGS64" \
    CXXFLAGS="$CXXFLAGS $CXXFLAGS64" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS64" \
    LDFLAGS="$LDFLAGS $LDFLAGS64" \
    CC="$CC -m64" CXX="$CXX -m64" \
    ABI=64 \
    MPN_PATH="$MPN64" \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_64 \
    $CONFIGURE_OPTS || \
        logerr "--- Configure failed"
}

# Installer only puts gmpxx.h in the right place but there are two more
fix_header_files() {
    logmsg "Putting all header files in the right spot"
    for file in mp.h gmp.h; do
        logcmd mv $DESTDIR$PREFIX/include/$file $DESTDIR$PREFIX/include/gmp/
    done
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
fix_header_files
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
