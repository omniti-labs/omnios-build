#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=gnutls     # App name
VER=3.0.15      # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=library/gnutls  # Package name (without prefix)
SUMMARY="GNU transport layer security library"
DESC="$SUMMARY"

DEPENDS_IPS="library/libtasn1 library/security/libgpg-error library/security/nettle
             library/zlib system/library system/library/gcc-4-runtime"

LDFLAGS32="$LDFLAGS32 -L/usr/lib"
LDFLAGS64="$LDFLAGS64 -L/usr/lib/$ISAPART64"

CONFIGURE_OPTS="--disable-static"

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

# Vim hints
# vim:ts=4:sw=4:et:
