#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=myapp      # App name
VER=1.0         # App version
VERHUMAN=$VER   # Human readable version
PVER=0.1        # Branch version
PKG=cat/pkg     # Package name (without prefix)
SUMMARY=""      # Change this
DESC=""         # Change this

DEPENDS_IPS="runtime/python-26"

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_package
clean_up
