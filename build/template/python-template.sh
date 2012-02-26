#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=myapp      # App name
VER=1.0         # App version
VERHUMAN=$VER   # Human readable version
PVER=0.1        # Branch version
PKG=cat/pkg     # Package name (without prefix)
SUMMARY="$PROG - Packager was lazy and didn't fill this in"
DESC="$SUMMARY"

DEPENDS_IPS="runtime/python-26"

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_package
clean_up
