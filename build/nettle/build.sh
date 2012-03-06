#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=nettle     # App name
VER=2.4         # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=library/security/nettle  # Package name (without prefix)
SUMMARY="Nettle - a low-level cryptographic library"
DESC="$SUMMARY"

CONFIGURE_OPTS="--enable-shared"

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
