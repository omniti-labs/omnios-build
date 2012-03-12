#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=bind       # App name
VER=9.9.0       # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=network/dns/bind  # Package name (without prefix)
SUMMARY="BIND DNS tools"
DESC="$SUMMARY ($VER)"

DEPENDS_IPS="library/libxml2 library/security/openssl library/zlib
             system/library system/library/gcc-4-runtime system/library/math"

BUILDARCH=32

CONFIGURE_OPTS="
    --bindir=$PREFIX/sbin
    --sbindir=$PREFIX/sbin
    --libdir=$PREFIX/lib/dns
    --sysconfdir=/etc
    --localstatedir=/var
    --with-libtool
    --with-openssl
    --enable-threads=yes
    --enable-devpoll=yes
    --disable-openssl-version-check
    --enable-fixed-rrset
    --disable-getifaddrs
    --with-pkcs11
    --enable-shared
    --disable-static
"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
