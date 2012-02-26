#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=M2Crypto  # App name
VER=0.21.1     # App version
PVER=1         # Package Version
PKG=library/python-2/m2crypto # Package name (without prefix)
SUMMARY="Python interface for openssl"
DESC="M2Crypto provides a python interface to the openssl library."

DEPENDS_IPS="runtime/python-26 library/security/openssl@1.0.0"

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_package
clean_up
