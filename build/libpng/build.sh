#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=libpng     # App name
VER=1.5.9       # App version
PVER=1          # Package Version
PKG=image/library/libpng  # Package name (without prefix)
SUMMARY="Portable Network Graphics library"
DESC="$SUMMARY"

DEPENDS_IPS="library/zlib system/library system/library/math"

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
