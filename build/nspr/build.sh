#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=nspr      # App name
VER=4.9         # App version
VERHUMAN=$VER   # Human-readable version
PVER=0.1          # Package Version (numeric only)
PKG=$PROG ##IGNORE##
SUMMARY="Netscape Portable Runtime"      # You should change this
DESC="$SUMMARY"         # Longer description

CONFIGURE_OPTS="--includedir=/usr/include/mps"
CONFIGURE_OPTS_32="--libdir=/usr/lib/mps"
CONFIGURE_OPTS_64="--libdir=/usr/lib/mps/$ISAPART64 --enable-64bit"

secv1_links() {
    logcmd cp $TMPDIR/$BUILDDIR/pkg/solaris/common_files/copyright $DESTDIR/license
    logcmd ln -s amd64 $DESTDIR/usr/lib/mps/64
    logcmd mkdir -p $DESTDIR/usr/lib/mps/secv1/amd64
    logcmd ln -s amd64 $DESTDIR/usr/lib/mps/secv1/64
    logcmd mkdir -p $DESTDIR/usr/lib/pkgconfig
    logcmd cp $SRCDIR/files/nspr.pc $DESTDIR/usr/lib/pkgconfig
    for lib in libnspr4.so libplc4.so libplds4.so
    do
        ln -s ../../amd64/$lib $DESTDIR/usr/lib/mps/secv1/amd64/$lib
        ln -s ../$lib $DESTDIR/usr/lib/mps/secv1/$lib
    done
}

init
download_source $PROG $PROG $VER
BUILDDIR=$PROG-$VER/mozilla/nsprpub
patch_source
prep_build
build
secv1_links
make_isa_stub
fix_permissions

PKG=library/nspr/header-nspr
SUMMARY="Netscape Portable Runtime Headers"
DESC="$SUMMARY"
make_package header-nspr.mog

DEPENDS_IPS="SUNWcs system/library/gcc-4-runtime system/library"
PKG=library/nspr
SUMMARY="Netscape Portable Runtime"
DESC="$SUMMARY"
make_package nspr.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
