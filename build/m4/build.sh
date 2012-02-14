#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=m4         # App name
VER=1.4.16      # App version
PVER=1          # Package Version
PKG=developer/macro/gnu-m4  # Package name (without prefix)

BUILDARCH=32

make_sfw_links() {
    logmsg "Creating SFW symlinks"
    logcmd mkdir -p $DESTDIR/usr/sfw/bin
    pushd $DESTDIR/usr/sfw/bin > /dev/null
    logcmd ln -s ../../bin/gm4 gm4 || \
            logerr "Failed to create link for gm4"
    popd > /dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_sfw_links
fix_permissions
make_package
clean_up
