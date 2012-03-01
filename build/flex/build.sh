#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=flex       # App name
VER=2.5.35      # App version
PVER=2          # Package Version
PKG=developer/lexer/flex  # Package name (without prefix)
SUMMARY="$PROG - A fast lexical analyser generator"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="developer/macro/gnu-m4"

CONFIGURE_OPTS="--mandir=$PREFIX/share/man
	--infodir=$PREFIX/share/info"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --includedir=/usr/include"

make_sfw_links() {
    logmsg "Creating SFW symlinks"
    logcmd mkdir -p $DESTDIR/usr/sfw/bin
    pushd $DESTDIR/usr/sfw/bin > /dev/null
    logcmd ln -s ../../bin/flex flex || \
            logerr "Failed to create link for flex"
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
