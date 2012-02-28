#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=nss      # App name
VER=3.12.9         # App version
VERHUMAN=$VER   # Human-readable version
PVER=0.1          # Package Version (numeric only)
PKG=$PROG ##IGNORE##
SUMMARY="Netscape Portable Runtime"      # You should change this
DESC="$SUMMARY"         # Longer description

CONFIGURE_OPTS="--includedir=/usr/include/mps"
CONFIGURE_OPTS_32="--libdir=/usr/lib/mps"
CONFIGURE_OPTS_64="--libdir=/usr/lib/mps/$ISAPART64"

TGT_LIBS="libfreebl3.so libnss3.so
	libnssckbi.so libnssdbm3.so
	libnssutil3.so libsmime3.so
	libsoftokn3.so libssl3.so"

realize_links() {
    # WTF Mozilla? Seriously?
    pushd $DESTDIR$1 > /dev/null
    for lib in $TGT_LIBS
    do
        REAL=$(ls -l $lib | awk '/->/ {print $NF;}')
        logcmd rm $lib
        logcmd cp $REAL $lib
        logcmd chmod 755 $lib
    done
    popd > /dev/null
}
configure32() {
    logmsg "Building nsinstall and dbm"
    pushd $TMPDIR/$BUILDDIR/mozilla/security/coreconf/nsinstall > /dev/null
    logcmd gmake clean || logerr "Can't make clean"
    logcmd gmake || logerr "Can't build nsinstall"
    popd > /dev/null
    pushd $TMPDIR/$BUILDDIR/mozilla/security/dbm/ > /dev/null
    logcmd gmake clean || logerr "Can't make clean"
    logcmd gmake || logerr "Can't build dbm"
    popd > /dev/null
}
make_prog32() {
    logmsg "Making libraries (32)"
    pushd $TMPDIR/$BUILDDIR/mozilla/security/nss > /dev/null
    logcmd gmake clean || logerr "Can't make clean"
    logcmd gmake || logerr "build failed"
    logcmd gmake FREEBL_CHILD_BUILD=1 || logerr "build failed"
    logcmd gmake export || logerr "build failed"
    popd > /dev/null
}
make_install32() {
    logmsg "Installing libraries (32)"
    pushd $TMPDIR/$BUILDDIR/mozilla/security/nss > /dev/null
    logcmd gmake install FREEBL_CHILD_BUILD=1 SOURCE_LIB_DIR=$DESTDIR/usr/lib/mps || logerr "install failed"
    logmsg "Installing headers"
    logcmd mkdir -p $DESTDIR/usr/include/mps
    logcmd cp $TMPDIR/$BUILDDIR/mozilla/dist/public/nss/* $DESTDIR/usr/include/mps/
    logcmd cp $TMPDIR/$BUILDDIR/mozilla/dist/public/dbm/* $DESTDIR/usr/include/mps/
    popd > /dev/null
    realize_links /usr/lib/mps
}

configure64() {
    logmsg "Building nsinstall and dbm"
    pushd $TMPDIR/$BUILDDIR/mozilla/security/coreconf/nsinstall > /dev/null
    logcmd gmake clean || logerr "Can't clean install"
    logcmd gmake USE_64=1 || logerr "Can't build nsinstall"
    popd > /dev/null
    pushd $TMPDIR/$BUILDDIR/mozilla/security/dbm/ > /dev/null
    logcmd gmake clean || logerr "Can't make clean "
    logcmd gmake USE_64=1 || logerr "Can't build dbm"
    popd > /dev/null
}
make_prog64() {
    logmsg "Making libraries (64)"
    pushd $TMPDIR/$BUILDDIR/mozilla/security/nss > /dev/null
    logcmd gmake clean || logerr "Can't make clean"
    logcmd gmake USE_64=1 || logerr "build failed"
    logcmd gmake USE_64=1 FREEBL_CHILD_BUILD=1 || logerr "build failed"
    logcmd gmake USE_64=1 export || logerr "build failed"
    popd > /dev/null
}
make_install64() {
    logmsg "Installing libraries (64)"
    pushd $TMPDIR/$BUILDDIR/mozilla/security/nss > /dev/null
    logcmd gmake USE_64=1 FREEBL_CHILD_BUILD=1 install SOURCE_LIB_DIR=$DESTDIR/usr/lib/mps/amd64 || logerr "install failed"
    popd > /dev/null
    realize_links /usr/lib/mps/amd64
}
secv1_links() {
    logcmd cp $TMPDIR/$BUILDDIR//mozilla/security/nss/pkg/solaris/common_files/copyright $DESTDIR/license
    logcmd ln -s amd64 $DESTDIR/usr/lib/mps/64
    logcmd mkdir -p $DESTDIR/usr/lib/mps/secv1/amd64
    logcmd ln -s amd64 $DESTDIR/usr/lib/mps/secv1/64
    logcmd mkdir -p $DESTDIR/usr/lib/pkgconfig
    logcmd cp $SRCDIR/files/nss.pc $DESTDIR/usr/lib/pkgconfig
    for lib in $TGT_LIBS
    do
        ln -s ../../amd64/$lib $DESTDIR/usr/lib/mps/secv1/amd64/$lib
        ln -s ../$lib $DESTDIR/usr/lib/mps/secv1/$lib
    done
}

init
download_source $PROG $PROG $VER
patch_source
logmsg "Installing custom make definitions"
cp files/SunOS5.11_i86pc.mk $TMPDIR/$BUILDDIR/mozilla/security/coreconf
prep_build
build
secv1_links
make_isa_stub
fix_permissions

PKG=system/library/mozilla-nss/header-nss
SUMMARY="Netscape Portable Runtime Headers"
DESC="$SUMMARY"
make_package header-nss.mog

DEPENDS_IPS="SUNWcs system/library/gcc-4-runtime system/library
	library/nspr database/sqlite-3"
PKG=system/library/mozilla-nss
SUMMARY="Netscape Portable Runtime"
DESC="$SUMMARY"
make_package nss.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
