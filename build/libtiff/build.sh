#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=tiff       # App name
VER=4.0.1       # App version
PVER=1          # Package Version
PKG=image/library/libtiff  # Package name (without prefix)
SUMMARY="libtiff - library for reading and writing TIFF"
DESC="$SUMMARY"

DEPENDS_IPS="image/library/libjpeg library/zlib system/library system/library/gcc-4-runtime system/library/math"

CONFIGURE_OPTS="--disable-static"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
