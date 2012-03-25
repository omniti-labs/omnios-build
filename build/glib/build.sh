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

PROG=glib       # App name
VER=2.30.2      # App version
PVER=1          # Package Version
PKG=library/glib2 # Package name (without prefix)
SUMMARY="$PROG - GNOME GLib utility library"
DESC="$SUMMARY"

DEPENDS_IPS="SUNWcs library/libffi@3.0.10 library/zlib system/library
	system/library/gcc-4-runtime runtime/perl-5142"

CONFIGURE_OPTS="--disable-fam --disable-dtrace"

save_function configure32 configure32_orig
save_function configure64 configure64_orig
configure32() {
    LIBFFI_CFLAGS=-I/usr/lib/libffi-3.0.10/include
    export LIBFFI_CFLAGS
    LIBFFI_LIBS=-lffi
    export LIBFFI_LIBS
    configure32_orig
}
configure64() {
    LIBFFI_CFLAGS=-I/usr/lib/amd64/libffi-3.0.10/include
    export LIBFFI_CFLAGS
    LIBFFI_LIBS=-lffi
    export LIBFFI_LIBS
    configure64_orig
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up
