#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=pybonjour  # App name
VER=1.1.1        # App version
PVER=0.151002
PKG=library/python-2/pybonjour # Package name (without prefix)
SUMMARY="pure-Python interface bonjour/DNS-SD implementation"
DESC="$SUMMARY"

DEPENDS_IPS="runtime/python-26"

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_package
clean_up
