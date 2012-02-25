#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PATH=/opt/gcc-4.6.2/bin:$PATH
export LD_LIBRARY_PATH=/opt/gcc-4.6.2/lib

PROG=libstdc++   # App name
VER=4.6.2        # App version
VERHUMAN=$VER    # Human-readable version
PVER=1           # Package Version (numeric only)
PKG=system/library/g++-4-runtime  # Package name (without prefix)
SUMMARY="g++ runtime dependencis libstc++/libssp" # You should change this
DESC="$SUMMARY" # Longer description

BUILD_DEPENDS_IPS="gcc46"
DEPENDS_IPS="system/library/gcc-4-runtime"
NO_PARALLEL_MAKE=1

# This stuff is in its own domain
PKGPREFIX=""

PREFIX=/opt/gcc-4.6.2

init
prep_build
fix_permissions
mkdir -p $DESTDIR/usr/lib
mkdir -p $DESTDIR/usr/lib/amd64

LIB=libstdc++.so
cp /opt/gcc-4.6.2/lib/$LIB.6.0.16 $DESTDIR/usr/lib/$LIB.6.0.16
ln -s /usr/lib/$LIB.6.0.16 $DESTDIR/usr/lib/$LIB.6
ln -s /usr/lib/$LIB.6.0.16 $DESTDIR/usr/lib/$LIB
cp /opt/gcc-4.6.2/lib/amd64/$LIB.6.0.16 $DESTDIR/usr/lib/amd64/$LIB.6.0.16
ln -s /usr/lib/amd64/$LIB.6.0.16 $DESTDIR/usr/lib/amd64/$LIB.6
ln -s /usr/lib/amd64/$LIB.6.0.16 $DESTDIR/usr/lib/amd64/$LIB

LIB=libssp.so
cp /opt/gcc-4.6.2/lib/$LIB.0.0.0 $DESTDIR/usr/lib/$LIB.0.0.0
ln -s /usr/lib/$LIB.0.0.0 $DESTDIR/usr/lib/$LIB.0
ln -s /usr/lib/$LIB.0.0.0 $DESTDIR/usr/lib/$LIB
cp /opt/gcc-4.6.2/lib/amd64/$LIB.0.0.0 $DESTDIR/usr/lib/amd64/$LIB.0.0.0
ln -s /usr/lib/amd64/$LIB.0.0.0 $DESTDIR/usr/lib/amd64/$LIB.0
ln -s /usr/lib/amd64/$LIB.0.0.0 $DESTDIR/usr/lib/amd64/$LIB

make_package
clean_up
