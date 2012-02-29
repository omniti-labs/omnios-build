#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=setuptools  # App name
VER=0.6.11        # App version
PVER=0.1
PKG=library/python-2/setuptools-26 # Package name (without prefix)
SUMMARY="setuptools - yet another python packaging requirement"
DESC="$SUMMARY"

DEPENDS_IPS="runtime/python-26"

init
prep_build
mkdir -p $DESTDIR/usr/lib/python2.6/vendor-packages
PYTHONPATH=$DESTDIR/usr/lib/python2.6/vendor-packages \
    python2.6 ez_setup.py \
        --install-dir $DESTDIR/usr/lib/python2.6/vendor-packages/
make_package
clean_up
