#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=cups
VER=1.5.2      # App version
PVER=1          # Package Version
PKG=cups ##IGNORE##
SUMMARY="$PROG - common UNIX printing system libraries"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="image/library/libjpeg image/library/libpng image/library/libtiff
	library/security/openssl@1.0.0 library/zlib service/security/kerberos-5
	system/library/math system/library/security/gss system/library
	system/library/usb/libusb"

CONFIGURE_OPTS="--localstatedir=/var"

make_prog() {
    logmsg "--- dropping libssp dep"
    cp Makedefs Makedefs.backup
    sed -e 's/-fstack-protector//' < Makedefs.backup > Makedefs
    logmsg "--- make"
    logcmd $MAKE $MAKE_JOBS || logerr "--- Make (cups) failed"
}

make_prog64() {
    logmsg "--- MACH = amd64"
    echo "MACH = amd64" >> Makedefs
    make_prog
}

make_install() {
    logmsg "--- make install"
    logcmd $MAKE DSTROOT=${DESTDIR} install || \
        logerr "--- Make install failed"
    mkdir -p $DESTDIR/lib/svc/manifest/application
    cp scheduler/cups.xml $DESTDIR/lib/svc/manifest/application/cups.xml
    chmod 444 $DESTDIR/lib/svc/manifest/application/cups.xml
}

# We build backwards here on purpose so that 32bit binaries win (for install collisions).
build() {
    if [[ $BUILDARCH == "64" || $BUILDARCH == "both" ]]; then
        build64
    fi
    if [[ $BUILDARCH == "32" || $BUILDARCH == "both" ]]; then
        build32
    fi
}

init
download_source $PROG $PROG $VER-source
patch_source
prep_build
build
make_isa_stub
fix_permissions

PKG=print/cups
DEPENDS_IPS="SUNWcs libgcc_s library/print/cups-libs@1.4.2 library/security/openssl
	library/zlib libstdc++ service/security/kerberos-5 system/library/math
	system/library/security/gss system/library/usb/libusb system/library"
SUMMARY="Common Unix Print System"
DESC="Common Unix Print System"
make_package cups.mog

PKG=library/print/cups-libs
DEPENDS_IPS="image/library/libjpeg image/library/libpng image/library/libtiff
	library/security/openssl@1.0.0 library/zlib service/security/kerberos-5
	system/library/math system/library/security/gss system/library"
SUMMARY="Common Unix Print System libraries"
DESC="Common Unix Print System libraries"
make_package cups-libs.mog

clean_up
