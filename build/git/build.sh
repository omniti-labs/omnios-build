#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=git      # App name
VER=1.7.9.1   # App version
PVER=1        # Package Version
PKG=developer/versioning/git # Package name (without prefix)
SUMMARY="$PROG - a free and open source, distributed version control system"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="compatibility/ucb"

DEPENDS_SVR4="OMNIpython26 OMNIcurl OMNIlibiconv OMNIopenssl OMNIzlib OMNIperl"
DEPENDS_IPS="runtime/python-26 \
             web/curl \
             library/security/openssl@1.0.0
             library/zlib"

# For inet_ntop which isn't detected properly in the configure script
LDFLAGS="-lnsl"
CFLAGS64="$CFLAGS64 -I/usr/include/amd64"
CONFIGURE_OPTS="--without-tcltk
    --with-python=/usr/bin/python
    --with-curl=/usr
    --with-openssl=/usr"

save_function configure32 configure32_orig
configure32() {
    make_param configure
    configure32_orig
}

save_function configure64 configure64_orig
configure64() {
    make_param configure
    configure64_orig
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up
