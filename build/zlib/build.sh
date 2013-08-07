#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=zlib
VER=1.2.7
PKG=library/zlib
SUMMARY="$PROG - A massively spiffy yet delicately unobtrusive compression library"
DESC="$SUMMARY"

DEPENDS_IPS="system/library/gcc-4-runtime"

CFLAGS="-DNO_VIZ"

CONFIGURE_OPTS_32="--prefix=$PREFIX
    --includedir=$PREFIX/include
    --libdir=$PREFIX/lib"

CONFIGURE_OPTS_64="--prefix=$PREFIX
    --includedir=$PREFIX/include
    --libdir=$PREFIX/lib/$ISAPART64"

install_license(){
    # This is fun, strip fromt he zlib.h header
    /bin/awk '/Copyright/,/\*\//{if($1 != "*/"){print}}' \
        $TMPDIR/$BUILDDIR/zlib.h > $DESTDIR/license
}

make_prog32() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd gmake LDSHARED="gcc -shared -nostdlib" || logerr "gmake failed"
    popd > /dev/null
}

make_prog64() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd gmake LDSHARED="gcc -shared -nostdlib" || logerr "gmake failed"
    popd > /dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
install_license
make_package
clean_up
