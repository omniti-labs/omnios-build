#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=gnu-ghostscript       # App name
VER=9.04.1      # App version
MAJ_MIN_VER=9.04
PVER=1          # Package Version
PKG=print/filter/ghostscript    # Package name (without prefix)
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
fix_permissions
make_package
clean_up
