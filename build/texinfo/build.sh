#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=texinfo    # App name
VER=4.13        # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=text/texinfo  # Package name (without prefix)
SUMMARY="GNU texinfo - Texinfo utilities"
DESC="GNU texinfo $VER"

BUILDARCH=32

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
