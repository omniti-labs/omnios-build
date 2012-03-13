#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=fontconfig
VER=2.8.0
VERHUMAN=$VER
PVER=1
PKG=system/library/fontconfig
SUMMARY="Fontconfig - Font configuration and customization library"
DESC="$SUMMARY"

DEPENDS_IPS="library/expat system/library/freetype-2 system/library"

CONFIGURE_OPTS="
    --with-confdir=/etc/fonts
    --with-default-fonts='/usr/share/fonts'
    --with-add-fonts=/etc/X11/fontpath.d,/usr/share/ghostscript/fonts,/usr/X11/lib/X11/fonts
    --with-cache-dir=/var/cache/fontconfig
"

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
