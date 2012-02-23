#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=tar              # App name
VER=1.26              # App version
PVER=1                # Package Version (numeric only)
PKG=archiver/gnu-tar  # Package name (without prefix)
SUMMARY="gtar - GNU tar"
DESC="GNU tar - A utility used to store, backup, and transport files (gtar) $VER"

# GNU tar doesn't like to be configured by root.  This var ignores those errors
export FORCE_UNSAFE_CONFIGURE=1

CONFIGURE_OPTS="--program-prefix=g --with-rmt=/usr/sbin/rmt"

make_sym_links() {
    logmsg "Creating necessary symlinks"
    logmsg "--- usr/sfw/bin/gtar"
    logcmd mkdir -p $DESTDIR/usr/sfw/bin
    pushd $DESTDIR/usr/sfw/bin > /dev/null
    logcmd ln -s ../../bin/gtar gtar || \
            logerr "Failed to create link for usr/sfw/bin/gtar"
    popd > /dev/null
    logmsg "--- usr/gnu/bin/tar"
    logcmd mkdir -p $DESTDIR/usr/gnu/bin
    pushd $DESTDIR/usr/gnu/bin > /dev/null
    logcmd ln -s ../../bin/gtar tar || \
            logerr "Failed to create link for usr/bin/gtar"
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
