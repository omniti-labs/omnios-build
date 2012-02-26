#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

export LD_LIBRARY_PATH=/opt/gcc-4.6.2/lib
PATH=/usr/perl5/5.10.0/bin:$PATH
export PATH

PROG=gcc         # App name
VER=4.6.2        # App version
VERHUMAN=$VER    # Human-readable version
PVER=3           # Package Version (numeric only)
PKG=developer/gcc46        # Package name (without prefix)
SUMMARY="gcc 4.6.2" # You should change this
DESC="$SUMMARY" # Longer description

DEPENDS_IPS="developer/gcc46/libgmp-gcc46 developer/gcc46/libmpfr-gcc46 developer/gcc46/libmpc-gcc46
	developer/gnu-binutils system/library/gcc-4-runtime"
NO_PARALLEL_MAKE=1

# This stuff is in its own domain
PKGPREFIX=""

[[ "$BUILDARCH" == "both" ]] && BUILDARCH=32
PREFIX=/opt/gcc-4.6.2
reset_configure_opts
CC=gcc

LD_FOR_TARGET=/bin/ld
export LD_FOR_TARGET
LD_FOR_HOST=/bin/ld
export LD_FOR_HOST
LD=/bin/ld
export LD

CONFIGURE_OPTS_32="--prefix=/opt/gcc-4.6.2"
CONFIGURE_OPTS="--host i386-pc-solaris2.11 --build i386-pc-solaris2.11 --target i386-pc-solaris2.11 \
	--with-boot-ldflags=-R/opt/gcc-4.6.2/lib \
	--with-gmp=/opt/gcc-4.6.2 --with-mpfr=/opt/gcc-4.6.2 --with-mpc=/opt/gcc-4.6.2 \
	--enable-languages=c,c++,fortran,lto --enable-ld=no \
	--with-as=/usr/bin/gas --with-gnu-as --with-build-time-tools=/usr/gnu/i386-pc-solaris2.11/bin"
LDFLAGS32="-R/opt/gcc-4.6.2/lib"
export LD_OPTIONS="-zignore -zcombreloc -Bdirect -i"

save_function configure32 configure32_orig
configure32() {
    logmsg "This is evil... sudo chmod'ing gnu ld"
    logcmd sudo chmod 644 /usr/gnu/i386-pc-solaris2.11/bin/ld
    configure32_orig
    logmsg "This is evil... chmodding gnu ld back"
    logcmd sudo chmod 755 /usr/gnu/i386-pc-solaris2.11/bin/ld
}

init
download_source $PROG/releases/$PROG-$VER $PROG $VER
patch_source
prep_build
build
fix_permissions
make_package
clean_up
