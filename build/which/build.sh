#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=which      # App name
VER=2.20        # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=shell/which # Package name (without prefix)
SUMMARY="GNU which"
DESC="GNU which utility ($VER)"

DEPENDS_IPS="system/library"

BUILDARCH=32

PREFIX=/usr/gnu
reset_configure_opts
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
