#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=readline   # App name
VER=6.2         # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=library/readline  # Package name (without prefix)
SUMMARY="GNU readline"
DESC="GNU readline library ($VER)"

DEPENDS_IPS="system/library system/library/gcc-4-runtime"

CONFIGURE_OPTS="--disable-static"

save_function fix_permissions fix_permissions_orig
fix_permissions() {
    fix_permissions_orig
    logmsg "--- Making shared libs executable"
    for file in libhistory libreadline; do
        logcmd chmod 0555 $DESTDIR$PREFIX/lib/${file}.so.*
        logcmd chmod 0555 $DESTDIR$PREFIX/lib/$ISAPART64/${file}.so.*
    done
}

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
