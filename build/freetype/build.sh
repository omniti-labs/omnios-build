#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=freetype
VER=2.4.8
VERHUMAN=$VER
PVER=0.1
PKG=system/library/freetype-2
SUMMARY="FreeType 2 font engine"
DESC="FreeType 2 font engine"

DEPENDS_IPS="library/zlib compress/bzip2 system/library system/library/gcc-4-runtime"

GNUMAKE=gmake
export GNUMAKE
CONFIGURE_OPTS="--with-zlib --with-pic --enable-biarch-config --disable-static"
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --includedir=/usr/include"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --includedir=/usr/include"

install_license() {
    for lic in LICENSE.TXT FTL.TXT GPLv2.TXT
    do
        cp $TMPDIR/$BUILDDIR/docs/$lic $DESTDIR/$lic
    done
}
init
download_source freetype2 $PROG $VER
patch_source
prep_build
build
install_license
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
