#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=gmp         # App name
VER=5.0.4        # App version
VERHUMAN=$VER    # Human-readable version
PVER=1           # Package Version (numeric only)
PKG=library/gmp  # Package name (without prefix)
SUMMARY="GNU MP $VER"
DESC="The GNU Multiple Precision (Bignum) Library ($VER)"

# Cribbed from upstream, used to set MPN_PATH during configure
MPN32="x86/pentium x86 generic"
MPN64="x86_64/pentium4 x86_64 generic"
export MPN32 MPN64

CFLAGS="-fexceptions"
CONFIGURE_OPTS="--includedir=/usr/include/gmp 
                --localstatedir=/var 
                --enable-shared 
                --disable-static
                --disable-libtool-lock
                --disable-alloca
                --enable-cxx
                --enable-fft
                --enable-mpbsd
                --disable-fat
                --with-pic"

configure32() {
    logmsg "--- configure (32-bit)"
    CFLAGS="$CFLAGS $CFLAGS32" \
    CXXFLAGS="$CXXFLAGS $CXXFLAGS32" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS32" \
    LDFLAGS="$LDFLAGS $LDFLAGS32" \
    CC=$CC CXX=$CXX \
    ABI=32 \
    MPN_PATH="$MPN32" \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_32 \
    $CONFIGURE_OPTS || \
        logerr "--- Configure failed"
}

configure64() {
    logmsg "--- configure (64-bit)"
    CFLAGS="$CFLAGS $CFLAGS64" \
    CXXFLAGS="$CXXFLAGS $CXXFLAGS64" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS64" \
    LDFLAGS="$LDFLAGS $LDFLAGS64" \
    CC=$CC CXX=$CXX \
    ABI=64 \
    MPN_PATH="$MPN64" \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_64 \
    $CONFIGURE_OPTS || \
        logerr "--- Configure failed"
}

# Installer only puts gmpxx.h in the right place but there are two more
fix_header_files() {
    logmsg "Putting all header files in the right spot"
    for file in mp.h gmp.h; do
        logcmd mv $DESTDIR$PREFIX/include/$file $DESTDIR$PREFIX/include/gmp/
    done
}

init
download_source $PROG $PROG $VER
prep_build
build
fix_header_files
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
