#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=tar              # App name
VER=1.26              # App version
PVER=1                # Package Version (numeric only)
PKG=archiver/gnu-tar  # Package name (without prefix)
SUMMARY="gnu-tar - GNU tar archiving program"
DESC="$SUMMARY"

# GNU tar doesn't like to be configured by root.  This var ignores those errors
export FORCE_UNSAFE_CONFIGURE=1

PREFIX=/usr/gnu
reset_configure_opts

CONFIGURE_OPTS="--infodir=/usr/share/info --mandir=/usr/share/man --with-rmt=/usr/sbin/rmt"

make_sym_links() {
    logmsg "Creating necessary symlinks"
    logmsg "--- usr/sfw/bin/gtar"
    logcmd mkdir -p $DESTDIR/usr/sfw/bin
    pushd $DESTDIR/usr/sfw/bin > /dev/null
    logcmd ln -s ../../gnu/bin/tar gtar || \
            logerr "Failed to create link for usr/sfw/bin/gtar"
    popd > /dev/null
    logmsg "--- usr/bin/gtar"
    logcmd mkdir -p $DESTDIR/usr/bin
    pushd $DESTDIR/usr/bin > /dev/null
    logcmd ln -s ../gnu/bin/tar gtar || \
            logerr "Failed to create link for usr/bin/gtar"
    popd > /dev/null
    logmsg "--- usr/gnu/share/man/man1/tar.1"
    logcmd mkdir -p $DESTDIR/usr/gnu/share/man/man1
    pushd $DESTDIR/usr/gnu/share/man/man1 > /dev/null
    logcmd ln -s ../../../share/man/man1/gtar.1 tar.1 || \
            logerr "Failed to create link for usr/gnu/share/man/man1/tar.1"
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
logerr "Check install"
make_package
clean_up
