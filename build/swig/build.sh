#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=swig       # App name
VER=1.3.40      # App version
PVER=1          # Package Version
PKG=developer/swig  # Package name (without prefix)
SUMMARY="The Simplified and Interface Generator (swig)"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="runtime/perl-5142 runtime/python-26"

CONFIGURE_OPTS="--disable-ccache"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up
