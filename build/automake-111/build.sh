#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=automake   # App name
VER=1.11.3      # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=developer/build/automake-111  # Package name (without prefix)
SUMMARY="GNU Automake $VER"
DESC="GNU Automake - A Makefile generator ($VER)"

BUILDARCH=32
DEPENDS_IPS="developer/macro/gnu-m4 runtime/perl-510"

# Since it's 32-bit only we don't worry about isaexec for bins
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
