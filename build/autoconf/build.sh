#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=autoconf                 # App name
VER=2.68                      # App version
PVER=1                        # Package Version
PKG=developer/build/autoconf  # Package name (without prefix)
SUMMARY="autoconf - GNU autoconf utility"
DESC="GNU autoconf - GNU autoconf utility ($VER)"

NO_PARALLEL_MAKE=1
BUILDARCH=32

DEPENDS_IPS="developer/macro/gnu-m4 runtime/perl-510"

CONFIGURE_OPTS="--infodir=$PREFIX/share/info"

make_sfw_links() {
    logmsg "Creating SFW symlinks"
    logcmd mkdir -p $DESTDIR/$PREFIX/sfw/bin
    pushd $DESTDIR/$PREFIX/sfw/bin > /dev/null
    for file in autoscan autoheader autom4te ifnames autoconf autoreconf autoupdate
        do logcmd ln -s ../../bin/$file $file || \
            logerr "Failed to create link for $file"
        done
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

# Vim hints
# vim:ts=4:sw=4:et:
