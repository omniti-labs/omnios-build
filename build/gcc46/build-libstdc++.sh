#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PATH=/opt/gccstage/bin:$PATH
export LD_LIBRARY_PATH=/opt/gccstage/lib

PROG=libstdc++   # App name
VER=4.6.2        # App version
VERHUMAN=$VER    # Human-readable version
PVER=1           # Package Version (numeric only)
PKG=libstdc++    # Package name (without prefix)
SUMMARY="libstc++" # You should change this
DESC="$SUMMARY (OmniTI roll)" # Longer description

BUILD_DEPENDS_IPS="gcc46"
NO_PARALLEL_MAKE=1

# This stuff is in its own domain
PKGPREFIX=""

PREFIX=/opt/gcc-4.6.2

init
prep_build
fix_permissions
mkdir -p $DESTDIR/usr/lib
LIB=libstdc++.so
cp /opt/gcc-4.6.2/lib/$LIB.6.0.16 $DESTDIR/usr/lib/$LIB.6.0.16
ln -s /usr/lib/$LIB.6.0.16 $DESTDIR/usr/lib/$LIB.6
ln -s /usr/lib/$LIB.6.0.16 $DESTDIR/usr/lib/$LIB
mkdir -p $DESTDIR/usr/lib/amd64
cp /opt/gcc-4.6.2/lib/amd64/$LIB.6.0.16 $DESTDIR/usr/lib/amd64/$LIB.6.0.16
ln -s /usr/lib/amd64/$LIB.6.0.16 $DESTDIR/usr/lib/amd64/$LIB.6
ln -s /usr/lib/amd64/$LIB.6.0.16 $DESTDIR/usr/lib/amd64/$LIB
make_package
clean_up
