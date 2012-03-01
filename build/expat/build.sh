#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=expat      # App name
VER=2.0.1       # App version
PVER=0.151002  # Package Version
PKG=library/expat      # Package name (without prefix)
SUMMARY="libexpat - XML parser library"
DESC="$SUMMARY"
BUILDDIR=$PROG-2007-06-05

CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --includedir=/usr/include"
init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
sync
make_package
clean_up
