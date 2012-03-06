#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=libgpg-error  # App name
VER=1.10        # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=library/security/libgpg-error  # Package name (without prefix)
SUMMARY="Common error codes for GnuPG, libgcrypt"
DESC="$SUMMARY"

DEPENDS_IPS="system/library system/library/gcc-4-runtime"

CONFIGURE_OPTS="--disable-static"

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
