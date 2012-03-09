#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=unixODBC   # App name
VER=2.2.14      # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=library/unixodbc  # Package name (without prefix)
SUMMARY="The UnixODBC Subsystem and SDK"
DESC="UnixODBC - The UnixODBC Subsystem and SDK ($VER)"

DEPENDS_IPS="system/library system/library/math system/library/gcc-4-runtime"

CONFIGURE_OPTS="
    --includedir=$PREFIX/include/odbc
    --localstatedir=/var
    --sysconfdir=/etc/odbc
    --enable-shared
    --disable-static
    --disable-libtool-lock
    --disable-gui
    --enable-threads
    --disable-gnuthreads
    --enable-readline
    --enable-inicaching
    --enable-drivers=yes
    --enable-driver-conf=yes
    --enable-fdb
    --enable-odbctrace
    --enable-iconv
    --enable-stats
    --enable-rtldgroup
    --disable-ltdllib
    --without-pth
    --without-pth-test
    --with-libiconv-prefix=$PREFIX
    --disable-ltdl-install
    --with-pic
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
