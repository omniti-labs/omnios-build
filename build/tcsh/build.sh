#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=tcsh       # App name
VER=6.18.01     # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=shell/tcsh  # Package name (without prefix)
SUMMARY="Tenex C-shell (tcsh)"
DESC="$SUMMARY $VER"

DEPENDS_IPS="system/library"

BUILDARCH=32

CONFIGURE_OPTS="--bindir=$PREFIX/bin"

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
