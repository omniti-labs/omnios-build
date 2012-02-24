#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=lcms2       # App name
VER=2.3      # App version
PVER=1          # Package Version
PKG=library/print/lcms2    # Package name (without prefix)
SUMMARY="$PROG - little color management system"
DESC="$SUMMARY"

DEPENDS_IPS=""

CONFIGURE_OPTS=""

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up
