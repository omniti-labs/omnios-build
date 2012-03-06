#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=zsh
VER=4.3.17
VERHUMAN=$VER
PVER=0.1
PKG=shell/zsh
SUMMARY="Z shell"
DESC="Z shell"

DEPENDS_IPS="system/library system/library/math library/pcre"

BUILDARCH=32
CPPFLAGS32="$CPPFLAGS32 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --bindir=/usr/bin
	--enable-dynamic
	--enable-etcdir=/etc
	--enable-function-subdirs
	--enable-ldflags=-zignore
	--enable-libs=-lnsl
	--enable-maildir-support
	--enable-multibyte
	--enable-pcre
	--with-tcsetpgrp
	--disable-gdbm"

install_zshrc() {
  mkdir -p $DESTDIR/etc
  cp $SRCDIR/files/system-zshrc $DESTDIR/etc/zshrc
  chmod 644 $DESTDIR/etc/zshrc
}
install_license() {
  iconv -f 8859-1 -t utf-8 $SRCDIR/LICENSE > $DESTDIR/LICENSE
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
install_zshrc
install_license
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
