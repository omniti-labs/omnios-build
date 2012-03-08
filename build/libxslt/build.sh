#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=libxslt    # App name
VER=1.1.26      # App version
PVER=1          # Package Version
PKG=library/libxslt  # Package name (without prefix)
SUMMARY="The XSLT library"
DESC="$SUMMARY"

DEPENDS_IPS="library/libxml2 library/zlib system/library system/library/math"

CFLAGS32="$CFLAGS32 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
CFLAGS64="$CFLAGS64 -D_LARGEFILE_SOURCE"
LDFLAGS="-lpthread"

CONFIGURE_OPTS="--disable-static --with-pic --with-threads --without-crypto"
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --with-python=/usr/bin/$ISAPART/python2.6"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --with-python=/usr/bin/$ISAPART64/python2.6"

NO_PARALLEL_MAKE="true"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up
