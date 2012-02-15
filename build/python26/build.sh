#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PATH=/opt/gcc-4.6.2/bin:$PATH
export PATH
CC=/opt/gcc-4.6.2/bin/gcc
CXX=/opt/gcc-4.6.2/bin/g++

PROG=Python         # App name
VER=2.6.7           # App version
PVER=1              # Package Version
PKG=runtime/python-26 # Package name (without prefix)
SUMMARY="$PROG"
DESC="$SUMMARY"

DEPENDS_IPS="libgcc_s@4.6.2 library/zlib@1.2.6"

export CCSHARED="-fPIC"
CFLAGS="$CFLAGS -std=c99"
CPPFLAGS="$CPPFLAGS -I/usr/include/ncurses -D_LARGEFILE64_SOURCE"
CONFIGURE_OPTS="--enable-shared
	--with-system-ffi
	ac_cv_opt_olimit_ok=no
	ac_cv_olimit_ok=no"
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 BASECFLAGS=-m32"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 BASECFLAGS=-m64"

preprep_build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null || logerr "Cannot change to build directory"
    /opt/omni/bin/autoheader || logerr "autoheaer failed"
    /opt/omni/bin/autoconf || logerr "autoreconf failed"
    popd > /dev/null
}

post_config() {
    pushd $TMPDIR/$BUILDDIR > /dev/null || logerr "Cannot change to build directory"
    perl -pi -e 's/(^\#define _POSIX_C_SOURCE.*)/\/* $$1 *\//' pyconfig.h
    perl -pi -e 's/^(\#define _XOPEN_SOURCE.*)/\/* $$1 *\//' pyconfig.h
    perl -pi -e 's/^(\#define _XOPEN_SOURCE_EXTENDED.*)/\/* $$1 *\//' pyconfig.h
    popd > /dev/null
}

make_prog32() {
    post_config
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    logmsg "--- make"
    logcmd $MAKE $MAKE_JOBS DFLAGS=-32 || \
        logerr "--- Make failed"
}

make_prog64() {
    post_config
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    logmsg "--- make"
    logcmd $MAKE $MAKE_JOBS DFLAGS=-64 DESTSHARED=/usr/lib/python2.6/lib-dynload || \
        logerr "--- Make failed"
}

make_install32() {
    make_install
    rm $DESTDIR/usr/bin/i386/python || logerr "--- cannot remove arch hardlink"
}
make_install64() {
    logmsg "--- make install"
    logcmd $MAKE DESTDIR=${DESTDIR} install DESTSHARED=/usr/lib/python2.6/lib-dynload || \
        logerr "--- Make install failed"
    rm $DESTDIR/usr/bin/amd64/python || logerr "--- cannot remove arch hardlink"
    (cd $DESTDIR/usr/bin && ln -s python2.6 python) ||  logerr "--- could not setup python softlink"
}

init
download_source $PROG $PROG $VER
patch_source
preprep_build
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up
