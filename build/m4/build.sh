#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=m4         # App name
VER=1.4.16      # App version
PVER=2          # Package Version
PKG=developer/macro/gnu-m4  # Package name (without prefix)

PREFIX=/usr/gnu
reset_configure_opts

BUILDARCH=32
CONFIGURE_OPTS="--infodir=/usr/share/info"

make_sym_links() {
    logmsg "Creating various symlinks"
    logmsg "--- usr/sfw/bin/gm4"
    logcmd mkdir -p $DESTDIR/usr/sfw/bin
    pushd $DESTDIR/usr/sfw/bin > /dev/null
    logcmd ln -s ../../gnu/bin/m4 gm4 || \
            logerr "Failed to create link for usr/sfw/bin/gm4"
    popd > /dev/null
    logmsg "--- usr/bin/gm4"
    logcmd mkdir -p $DESTDIR/usr/bin
    pushd $DESTDIR/usr/bin > /dev/null
    logcmd ln -s ../gnu/bin/m4 gm4 || \
            logerr "Failed to create link for usr/bin/gm4"
    popd > /dev/null
    logmsg "--- usr/share/man/man1/gm4.1"
    logcmd mkdir -p $DESTDIR/usr/share/man/man1
    pushd $DESTDIR/usr/share/man/man1 > /dev/null
    logcmd ln -s ../../../gnu/share/man/man1/m4.1 gm4.1 || \
            logerr "Failed to create link for usr/share/man/man1/gm4.1"
    popd > /dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_sym_links
fix_permissions
make_package
clean_up
