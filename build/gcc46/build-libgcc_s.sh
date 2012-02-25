#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PATH=/opt/gcc-4.6.2/bin:$PATH
export LD_LIBRARY_PATH=/opt/gcc-4.6.2/lib

PROG=libgcc_s    # App name
VER=4.6.2        # App version
VERHUMAN=$VER    # Human-readable version
PVER=1           # Package Version (numeric only)
PKG=system/library/gcc-4-runtime # Package name (without prefix)
SUMMARY="gcc 4.6 runtime" # You should change this
DESC="$SUMMARY" # Longer description

BUILD_DEPENDS_IPS="gcc46"
NO_PARALLEL_MAKE=1

# This stuff is in its own domain
PKGPREFIX=""

PREFIX=/opt/gcc-4.6.2

init
prep_build
fix_permissions
mkdir -p $DESTDIR/usr/lib
cp /opt/gcc-4.6.2/lib/libgcc_s.so.1 $DESTDIR/usr/lib/libgcc_s.so.1
ln -s /usr/lib/libgcc_s.so.1 $DESTDIR/usr/lib/libgcc_s.so
mkdir -p $DESTDIR/usr/lib/amd64
cp /opt/gcc-4.6.2/lib/amd64/libgcc_s.so.1 $DESTDIR/usr/lib/amd64/libgcc_s.so.1
ln -s /usr/lib/amd64/libgcc_s.so.1 $DESTDIR/usr/lib/amd64/libgcc_s.so
make_package
clean_up
