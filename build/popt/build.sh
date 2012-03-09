#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=popt       # App name
VER=1.16        # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=library/popt  # Package name (without prefix)
SUMMARY="Command line parsing library"
DESC="$SUMMARY"

DEPENDS_IPS="system/library system/library/gcc-4-runtime"

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
