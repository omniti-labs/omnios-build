#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=ncurses    # App name
VER=5.9         # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=library/ncurses  # Package name (without prefix)
SUMMARY="A CRT screen handling and optimization package."
DESC="$SUMMARY"

DEPENDS_IPS="shell/bash system/library"

CFLAGS="-DBSD_COMP -fPIC -std=c99"
CXXFLAGS="-fPIC"
LD=/usr/ccs/bin/ld
export LD
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --libdir=/usr/gnu/lib"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --libdir=/usr/gnu/lib/$ISAPART64"
CONFIGURE_OPTS="
    --program-prefix=g
    --prefix=/usr/gnu
    --mandir=/usr/gnu/share/man
    --includedir=/usr/include/ncurses
    --with-normal
    --with-shared
    --enable-rpath
    --enable-widec
    --without-debug
"

gnu_links() {
    mkdir $DESTDIR/usr/gnu/bin
    mkdir $DESTDIR/usr/gnu/bin/{i386,amd64}
    mv $DESTDIR/usr/bin/ncurses5-config $DESTDIR/usr/gnu/bin/
    mv $DESTDIR/usr/bin/i386/ncurses5-config $DESTDIR/usr/gnu/bin/i386/
    mv $DESTDIR/usr/bin/amd64/ncurses5-config $DESTDIR/usr/gnu/bin/amd64/
    for cmd in captoinfo clear infocmp infotocap reset tic toe tput tset ; do
        ln -s ../../bin/g$cmd $DESTDIR/usr/gnu/bin/$cmd
    done
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
gnu_links
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
