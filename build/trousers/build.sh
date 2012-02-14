#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=trousers   # App name
VER=0.3.8       # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=library/security/trousers  # Package name (without prefix)
SUMMARY="trousers - TCG Software Stack - software for accessing a TPM device"
DESC="$SUMMARY ($VER)"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up
