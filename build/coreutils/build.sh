#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=coreutils          # App name
VER=8.15                # App version
PVER=1                  # Package Version
PKG=file/gnu-coreutils  # Package name (without prefix)
SUMMARY="coreutils - GNU core utilities"
DESC="GNU core utilities ($VER)"

DEPENDS_IPS="library/gmp system/library"

CPPFLAGS="-I/usr/include/gmp"
PREFIX=/usr/gnu
reset_configure_opts
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --libexecdir=/usr/lib"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --libexecdir=/usr/lib/$ISAPART64"

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
