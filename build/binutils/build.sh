#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=binutils               # App name
VER=2.22                    # App version
VERHUMAN=$VER               # Human-readable version
PVER=1                      # Package Version (numeric only)
PKG=developer/gnu-binutils  # Package name (without prefix)
SUMMARY="$PROG -  a collection of binary tools"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="gcc46"
[[ "$BUILDARCH" == "both" ]] && BUILDARCH=32

CONFIGURE_OPTS="--enable-ld=no --enable-gold=no --exec-prefix=/usr/gnu --program-prefix=g"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up
