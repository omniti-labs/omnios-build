#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=libxml2        # App name
VER=2.7.8           # App version
PVER=4              # Package Version
PKG=library/libxml2 # Package name (without prefix)
SUMMARY="$PROG - XML C parser and toolkit"
DESC="$SUMMARY"

DEPENDS_IPS="libgcc_s@4.6.2 library/zlib@1.2.6"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up
