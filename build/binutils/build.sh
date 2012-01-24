#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PATH=/opt/gcc-4.6.2/bin:$PATH
export PATH
CC=/opt/gcc-4.6.2/bin/gcc
CXX=/opt/gcc-4.6.2/bin/g++

PROG=binutils   # App name
VER=2.22        # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=$PROG       # Package name (without prefix)
SUMMARY="$PROG - Packager was lazy and didn't fill this in" # You should change this
DESC="$SUMMARY (OmniTI roll)" # Longer description

BUILD_DEPENDS_IPS="gcc46"
[[ "$BUILDARCH" == "both" ]] && BUILDARCH=32

CONFIGURE_OPTS="--enable-ld=no --enable-gold=no --exec-prefix=/opt/omni/gnu --program-prefix=g"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up
