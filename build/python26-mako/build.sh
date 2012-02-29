#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=Mako  # App name
VER=0.6.2        # App version
PVER=0.1
PKG=library/python-2/mako # Package name (without prefix)
SUMMARY="Mako - a python templating language"
DESC="$SUMMARY"

DEPENDS_IPS="runtime/python-26 library/python-2/setuptools-26"

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_package
clean_up
