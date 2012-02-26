#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=CherryPy  # App name
VER=3.2.2        # App version
PVER=1           # Package Version
PKG=library/python-2/cherrypy # Package name (without prefix)
SUMMARY="cherrypy - A Minimalist Python Web Framework"
DESC="$SUMMARY"

DEPENDS_IPS="runtime/python-26"

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_package
clean_up
