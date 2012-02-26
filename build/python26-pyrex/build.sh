#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=Pyrex  # App name
VER=0.9.9        # App version
PVER=0.1
PKG=library/python-2/pyrex-26 # Package name (without prefix)
SUMMARY="Pyrex - a Language for Writing Python Extension Modules"
DESC="$SUMMARY"

DEPENDS_IPS="runtime/python-26"

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build

mv $DESTDIR/usr/bin/pyrexc $DESTDIR/usr/bin/pyrexc2.6
ln -s ./pyrexc2.6 $DESTDIR/usr/bin/pyrexc

strip_install -x
make_package
clean_up
