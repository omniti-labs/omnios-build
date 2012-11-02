#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=xz
VER=5.0.4
VERHUMAN=$VER
PKG=compress/xz
SUMMARY="XZ Utils - general-purpose data compression software"
DESC="$SUMMARY"

init
download_source $PROG $PROG $VER
patch_source
run_autoconf
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
