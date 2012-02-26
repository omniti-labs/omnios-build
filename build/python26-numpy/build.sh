#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=numpy  # App name
VER=1.6.1        # App version
PVER=0.1
PKG=library/python-2/numpy-26 # Package name (without prefix)
SUMMARY="numpy - package for scientific computing with Python"
DESC="$SUMMARY"

DEPENDS_IPS="runtime/python-26"

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
strip_install -x
make_package
clean_up
