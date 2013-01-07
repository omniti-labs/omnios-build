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

PROG=llvm       # App name
VER=3.2         # App version
VERHUMAN=$VER   # Human-readable version
BUILDDIR="$PROG-$VER.src"
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=zero/lang/llvm  # Package name (e.g. library/foo)
SUMMARY="llvm"      # One-liner, must be filled in
DESC="llvm"         # Longer description, must be filled in

export REQUIRES_RTTI=1
CONFIGURE_OPTS="--enable-optimized --disable-assertions \
    --enable-targets=x86,x86_64,cpp --enable-pic=yes --enable-docs=no"

# llvm needs the flags directory inserted into the make file
make_prog64() {
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    logmsg "--- make"
    logcmd $MAKE $MAKE_JOBS \
        CFLAGS="$CFLAGS $CFLAGS64" \
        CXXFLAGS="$CXXFLAGS $CXXFLAGS64" \
        LDFLAGS="$LDFLAGS $LDFLAGS64" || \
        logerr "--- Make failed"
}

# llvm ignores the configure targets
make_install64() {
    logmsg "--- make install"
    logcmd $MAKE install \
                 PROJ_bindir="$PREFIX/bin/amd64" \
                 PROJ_libdir="$PREFIX/lib/amd64" \
                 DESTDIR=${DESTDIR} || \
        logerr "--- Make install failed"
}

init
download_source $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
