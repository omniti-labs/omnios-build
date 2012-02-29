#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=zlib         # App name
VER=1.2.6         # App version
PVER=1            # Package Version
PKG=library/zlib  # Package name (without prefix)
SUMMARY="$PROG - A massively spiffy yet delicately unobtrusive compression library"
DESC="$SUMMARY"

DEPENDS_IPS="system/library/gcc-4-runtime"

CFLAGS="-DNO_VIZ"

CONFIGURE_OPTS_32="--prefix=$PREFIX
    --includedir=$PREFIX/include
    --libdir=$PREFIX/lib"

CONFIGURE_OPTS_64="--prefix=$PREFIX
    --includedir=$PREFIX/include/$ISAPART64
    --libdir=$PREFIX/lib/$ISAPART64"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up
