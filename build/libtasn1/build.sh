#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=libtasn1   # App name
VER=2.11        # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=library/libtasn1  # Package name (without prefix)
SUMMARY="Tiny ASN.1 library"
DESC="$SUMMARY"

DEPENDS_IPS="system/library system/library/gcc-4-runtime"

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
