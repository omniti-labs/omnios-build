#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=idnkit     # App name
VER=1.0-src     # App version
VERHUMAN=1.0    # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=library/idnkit  # Package name (without prefix)
SUMMARY="Internationalized Domain Name kit (idnkit/JPNIC)"
DESC="Internationalized Domain Name kit (idnkit/JPNIC)"

DEPENDS_IPS="system/library"

CONFIGURE_OPTS="--disable-static --mandir=/usr/share/man"

install_license() {
  logcmd cp $TMPDIR/$BUILDDIR/LICENSE.txt $DESTDIR/LICENSE.txt || \
    logerr "license installation failed"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
install_license

VER=1.0
PKG=library/idnkit
SUMMARY="Internationalized Domain Name kit (idnkit/JPNIC)"
DESC="Internationalized Domain Name kit (idnkit/JPNIC)"
make_package lib.mog

VER=1.0
PKG=library/idnkit/header-idnkit
DEPENDS_IPS=""
SUMMARY="Internationalized Domain Name Support Developer Files"
DESC="Internationalized Domain Name Support Developer Files"
make_package headers.mog

VER=1.0
PKG=network/dns/idnconv
DEPENDS_IPS="library/idnkit"
SUMMARY="Internationalized Domain Name Support Utilities"
DESC="Internationalized Domain Name Support Utilities"
make_package bin.mog

clean_up

# Vim hints
# vim:ts=4:sw=4:et:
