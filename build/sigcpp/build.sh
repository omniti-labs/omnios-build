#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=libsigc++      # App name
VER=2.2.10          # App version
VERHUMAN=$VER   # Human-readable version
PVER=0.1        # Package Version (numeric only)
PKG=library/c++/sigcpp
SUMMARY="Libsigc++ - a library that implements typesafe callback system"
DESC="$SUMMARY"

DEPENDS_IPS="system/library system/library/math system/library/g++-4-runtime"

MAKE=/bin/gmake
export MAKE
CONFIGURE_OPTS="--includedir=/usr/include"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
