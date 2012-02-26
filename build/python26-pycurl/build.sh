#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=pycurl     # App name
VER=7.19.0      # App version
PVER=0.151002   # Package Version
PKG=library/python-2/pycurl # Package name (without prefix)
SUMMARY="Python bindings for libcurl"
DESC="PycURL provides a thin layer of Python bindings on top of libcurl."

DEPENDS_IPS="runtime/python-26 library/security/openssl@1.0.0 web/curl@7.24"

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
VER=7.19.0.1
make_package
clean_up
