#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=wget       # App name
VER=1.13.4      # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=web/wget    # Package name (without prefix)
SUMMARY="$PROG - a utility to retrieve files from the World Wide Web"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="developer/lexer/flex"
DEPENDS_IPS="library/libidn library/security/openssl@1.0.0"

CONFIGURE_OPTS="--with-ssl=openssl --mandir=$PREFIX/share/man"

BUILDARCH=32

make_sfw_links() {
    logmsg "Creating SFW symlinks"
    logcmd mkdir -p $DESTDIR/$PREFIX/sfw/bin
    pushd $DESTDIR/$PREFIX/sfw/bin > /dev/null
    logcmd ln -s ../../bin/wget wget || \
            logerr "Failed to create link for wget"
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
