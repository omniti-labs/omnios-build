#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=lxml  # App name
VER=2.3.3        # App version
PVER=0.1
PKG=library/python-2/lxml-26 # Package name (without prefix)
SUMMARY="lxml - Powerful and Pythonic XML processing library"
DESC="$SUMMARY"

DEPENDS_IPS="runtime/python-26 library/libxml2 library/libxslt"

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
strip_install -x
make_package
clean_up
