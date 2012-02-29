#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=groff       # App name
VER=1.21         # App version
PVER=1           # Package Version
PKG=text/groff    # Package name (without prefix)
SUMMARY="$PROG - GNU Troff typesetting package"
DESC="$SUMMARY"

DEPENDS_IPS="SUNWcs system/library/gcc-4-runtime system/library/g++-4-runtime
	runtime/perl-510 system/library/math system/library"

BUILDARCH=32
CONFIGURE_OPTS_32="--prefix=$PREFIX
        --sysconfdir=/etc
        --includedir=$PREFIX/include
        --bindir=$PREFIX/bin
        --sbindir=$PREFIX/sbin
        --libdir=$PREFIX/lib
        --libexecdir=$PREFIX/libexec"
CONFIGURE_OPTS="--without-x"

cleanup_gnuism() {
    GNUCLASH="diffmk eqn grn indxbib neqn nroff pic refer soelim"
    mkdir -p $DESTDIR/usr/gnu/bin
    for clash in $GNUCLASH ; do
        ln -s ../../bin/g$clash $DESTDIR/usr/gnu/bin/$clash
    done
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
strip_install
cleanup_gnuism
fix_permissions
make_package
clean_up
