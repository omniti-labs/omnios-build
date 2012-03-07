#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=iso-codes  # App name
VER=3.33        # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=data/iso-codes  # Package name (without prefix)
SUMMARY="ISO code lists and translations"
DESC="$SUMMARY"

BUILDARCH=32

# Upstream doesn't ship any of the translations, so we won't either
remove_translations() {
    logmsg "Removing translation files"
    logcmd rm -rf $DESTDIR$PREFIX/share/locale
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
remove_translations
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
