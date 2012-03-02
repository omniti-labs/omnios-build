#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=xz         # App name
VER=5.0.3       # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=compress/xz # Package name (without prefix)
SUMMARY="XZ Utils - general-purpose data compression software"
DESC="$SUMMARY"

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
