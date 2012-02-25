#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=bzip2          # App name
VER=1.0.6           # App version
PVER=1              # Package Version
PKG=compress/bzip2  # Package name (without prefix)
SUMMARY="The bzip compression utility"
DESC="$SUMMARY"

# We don't use configure, so explicitly export PREFIX
PREFIX=/usr
export PREFIX
export CC

configure32() {
  BINISA=$ISAPART
  LIBISA=""
  CFLAGS="-m32 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -Wall -Winline -O2"
  LDFLAGS="$LDFLAGS $LDFLAGS32"
  export BINISA LIBISA CFLAGS LDFLAGS
}

configure64() {
  BINISA=$ISAPART64
  LIBISA=$ISAPART64
  CFLAGS="-m64 -D_LARGEFILE64_SOURCE -Wall -Winline -O2"
  LDFLAGS="$LDFLAGS $LDFLAGS64"
  export BINISA LIBISA CFLAGS LDFLAGS
}

save_function make_clean make_clean_orig
make_clean() {
    make_clean_orig
    logcmd $MAKE -f Makefile-libbz2_so clean
}

# We need to build the shared lib using a second Makefile
make_shlib() {
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    logmsg "--- make (shared lib)"
    OLD_CFLAGS=$CFLAGS
    CFLAGS="-fPIC $CFLAGS"
    export CFLAGS
    logcmd $MAKE $MAKE_JOBS -f Makefile-libbz2_so || \
        logerr "--- Make failed (shared lib)"
    CFLAGS=$OLD_CFLAGS
    export CFLAGS
}

make_shlib_install() {
    logmsg "--- make install (shared lib)"
    logcmd $MAKE DESTDIR=${DESTDIR} -f Makefile-libbz2_so install || \
        logerr "--- Make install failed (shared lib)"
}


build32() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 32-bit"
    export ISALIST="$ISAPART"
    make_clean
    configure32
    make_shlib
    make_prog32
    make_install32
    popd > /dev/null
    unset ISALIST
    export ISALIST
}

build64() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 64-bit"
    make_clean
    configure64
    make_shlib
    make_prog64
    make_install64
    for src in libbz2.so libbz2.so.1
    do
        ln -s ./libbz2.so.1.0.6 $DESTDIR/usr/lib/$src
        ln -s ./libbz2.so.1.0.6 $DESTDIR/usr/lib/$ISAPART64/$src
    done
    popd > /dev/null
}


init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
strip_install
make_package
clean_up
