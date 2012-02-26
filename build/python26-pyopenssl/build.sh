#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=pyOpenSSL  # App name
VER=0.11        # App version
PVER=1          # Package Version
PKG=library/python-2/pyopenssl-26 # Package name (without prefix)
SUMMARY="pyOpenSSL - Python interface to the OpenSSL library for Python 2.6"
DESC="$SUMMARY"

DEPENDS_IPS="runtime/python-26 library/security/openssl@1.0.0"

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_package
clean_up
