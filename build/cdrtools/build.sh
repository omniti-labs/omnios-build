#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=cdrtools   # App name
VER=3.00        # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=media/cdrtools  # Package name (without prefix)
SUMMARY="CD creation utilities"
DESC="$SUMMARY ($VER)"

DEPENDS_IPS="system/library system/library/gcc-4-runtime"

MAKE="gmake GMAKE_NOWARN=true"

# cdrtools doesn't use configure, just make
configure32() {
    true
}

configure64() {
    true
}

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
