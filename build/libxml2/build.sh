#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=libxml2   # App name
VER=2.7.8      # App version
PVER=2         # Package Version
PKG=libxml2    # Package name (without prefix)
SUMMARY="$PROG - XML C parser and toolkit"
DESC="$SUMMARY (OmniTI roll)"

LDFLAGS32="-L/opt/omni/lib -R/opt/omni/lib"
LDFLAGS64="-L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up
