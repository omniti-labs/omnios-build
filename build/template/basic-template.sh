#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=myapp      # App name
VER=1.0         # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=$PROG       # Package name (without prefix)
SUMMARY=""      # You should change this
DESC=""         # Longer description

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
