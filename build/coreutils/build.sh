#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=coreutils          # App name
VER=8.15                # App version
PVER=1                  # Package Version
PKG=file/gnu-coreutils  # Package name (without prefix)
SUMMARY="coreutils - GNU core utilities"
DESC="GNU core utilities ($VER)"

BUILD_DEPENDS_IPS="compress/xz"
DEPENDS_IPS="library/gmp system/library"

CPPFLAGS="-I/usr/include/gmp"
PREFIX=/usr/gnu
reset_configure_opts
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --libexecdir=/usr/lib --bindir=/usr/gnu/bin"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --libexecdir=/usr/lib/$ISAPART64"

link_in_usr_bin() {
    mkdir -p $DESTDIR/usr/bin
    for cmd in [ base64 dir dircolors ginstall md5sum nproc pinky printenv \
	ptx readlink seq sha1sum sha224sum sha256sum sha384sum sha512sum \
	shred shuf stat stdbuf tac timeout truncate users vdir whoami 
    do
        ln $DESTDIR/usr/gnu/bin/$cmd $DESTDIR/usr/bin/$cmd
    done
}
license(){
    cp $TMPDIR/BUILDDIR/COPYING $DESTDIR/license
}
init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
link_in_usr_bin
fix_permissions
license
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
