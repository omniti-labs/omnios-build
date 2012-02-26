#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=simplejson  # App name
VER=2.3.2        # App version
PVER=1           # Package Version
PKG=library/python-2/simplejson-26 # Package name (without prefix)
SUMMARY="simplejson - Python interface to JSON for Python 2.6"
DESC="$SUMMARY"

DEPENDS_IPS="runtime/python-26"

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_package
clean_up
