#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=vim        # App name
VER=7.3         # App version
PVER=1          # Package Version
PKG=editor/vim  # Package name (without prefix)
SUMMARY="Vi IMproved"
DESC="$SUMMARY version $VER"

BUILDDIR=${PROG}${VER/./}     # Location of extracted source
BUILDARCH=32

DEPENDS_IPS="system/extended-system-utilities system/library system/library/math"

# We're only shipping 32-bit so forgo isaexec
CONFIGURE_OPTS="
    --bindir=$PREFIX/bin
    --with-features=huge
    --without-x
    --disable-gui
    --disable-gtktest
"
reset_configure_opts

# The build doesn't supply a 'vi' symlink so we make one
link_vi() {
    logmsg "Creating symlink for $PREFIX/bin/vi"
    logcmd ln -s vim $DESTDIR$PREFIX/bin/vi
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
link_vi
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
