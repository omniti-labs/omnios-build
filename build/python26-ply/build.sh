#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=ply  # App name
VER=3.4        # App version
PVER=0.1
PKG=library/python-2/ply # Package name (without prefix)
SUMMARY="ply - Python lex and yacc"
DESC="$SUMMARY"

DEPENDS_IPS="runtime/python-26"

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_package
clean_up
