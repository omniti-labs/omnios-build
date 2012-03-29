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

PROG=gnu-ghostscript
VER=9.04.1
MAJ_MIN_VER=9.04
PKG=print/filter/ghostscript
SUMMARY="$PROG - tool suite for dealing with printable formats"
DESC="$SUMMARY"

DEPENDS_IPS="system/library/fontconfig@2.8.0 image/library/libpng image/library/libjpeg
	image/library/libtiff library/zlib"

NO_PARALLEL_MAKE=1
BUILDARCH=32

CONFIGURE_OPTS_32="--prefix=$PREFIX
	--sysconfdir=/etc
	--includedir=$PREFIX/include
	--bindir=$PREFIX/bin
	--sbindir=$PREFIX/sbin
	--libdir=$PREFIX/lib
	--libexecdir=$PREFIX/libexec"

CONFIGURE_OPTS="--with-drivers=ALL --without-omni --with-jbig2dec --with-jasper --enable-dynamic
	--disable-gtk --disable-dbus --disable-gtk --disable-sse2 --without-ijs --without-luratech
	--enable-cups --disable-compile-inits --disable-freetype
	--with-fontpath=/usr/share/ghostscript/${MAJ_MIN_VER}/Resource:/usr/share/ghostscript/${MAN_MIN_VER}/Resource/Font:/usr/share/ghostscript/fonts:/usr/openwin/lib/X11/fonts/Type1:/usr/openwin/lib/X11/fonts/TrueType:/usr/openwin/lib/X11/fonts/Type3:/usr/X11/lib/X11/fonts/Type1:/usr/X11/lib/fonts/TrueType:/usr/X11/lib/X11/fonts/Type3:/usr/X11/lib/X11/fonts/Resource:/usr/X11/lib/X11/Resource/Font"
CUPSCONFIG=/usr/bin/cups-config
export CUPSCONFIG

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
# This is a 32-bit only build (no libs)
# make_isa_stub
make_package
clean_up
