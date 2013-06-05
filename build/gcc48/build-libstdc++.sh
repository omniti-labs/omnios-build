#!/usr/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=libstdc++
VER=4.8.1
VERHUMAN=$VER
PKG=system/library/g++-4-runtime
SUMMARY="g++ runtime dependencis libstc++/libssp"
DESC="$SUMMARY"

PATH=/opt/gcc-${VER}/bin:$PATH
export LD_LIBRARY_PATH=/opt/gcc-${VER}/lib

BUILD_DEPENDS_IPS="gcc48 gcc44"
if [ -f /usr/lib/libstdc++.so.6.0.16 ]; then
    GCC46_LOC=/usr/lib
else
    GCC46_LOC=/opt/gcc-4.6.3/lib
    BUILD_DEPENDS_IPS="$BUILD_DEPENDS_IPS gcc46"
fi

if [ -f /usr/lib/libstdc++.so.6.0.17 ]; then
    GCC47_LOC=/usr/lib
else
    GCC47_LOC=/opt/gcc-4.7.2/lib
    BUILD_DEPENDS_IPS="$BUILD_DEPENDS_IPS gcc47"
fi

DEPENDS_IPS="system/library/gcc-4-runtime"
NO_PARALLEL_MAKE=1

# This stuff is in its own domain
PKGPREFIX=""

PREFIX=/opt/gcc-${VER}

init
prep_build
mkdir -p $TMPDIR/$BUILDDIR
for license in COPYING.RUNTIME COPYING.LIB COPYING3.LIB
do
    logcmd cp $SRCDIR/files/$license $TMPDIR/$BUILDDIR/$license || \
        logerr "Cannot copy licnese: $license"
done

mkdir -p $DESTDIR/usr/lib
mkdir -p $DESTDIR/usr/lib/amd64

LIB=libstdc++.so
cp /opt/gcc-4.4.4/lib/$LIB.6.0.13 $DESTDIR/usr/lib/$LIB.6.0.13
cp ${GCC46_LOC}/$LIB.6.0.16 $DESTDIR/usr/lib/$LIB.6.0.16
cp ${GCC47_LOC}/$LIB.6.0.17 $DESTDIR/usr/lib/$LIB.6.0.17
cp /opt/gcc-${VER}/lib/$LIB.6.0.18 $DESTDIR/usr/lib/$LIB.6.0.18 || logerr "Failed to copy 6.0.18"
ln -s /usr/lib/$LIB.6.0.18 $DESTDIR/usr/lib/$LIB.6
ln -s /usr/lib/$LIB.6.0.18 $DESTDIR/usr/lib/$LIB
cp /opt/gcc-4.4.4/lib/amd64/$LIB.6.0.13 $DESTDIR/usr/lib/amd64/$LIB.6.0.13
cp ${GCC46_LOC}/amd64/$LIB.6.0.16 $DESTDIR/usr/lib/amd64/$LIB.6.0.16
cp ${GCC47_LOC}/amd64/$LIB.6.0.17 $DESTDIR/usr/lib/amd64/$LIB.6.0.17
cp /opt/gcc-${VER}/lib/amd64/$LIB.6.0.18 $DESTDIR/usr/lib/amd64/$LIB.6.0.18 || logerr "Failed to copy 6.0.18 (amd64)"
ln -s /usr/lib/amd64/$LIB.6.0.18 $DESTDIR/usr/lib/amd64/$LIB.6
ln -s /usr/lib/amd64/$LIB.6.0.18 $DESTDIR/usr/lib/amd64/$LIB

LIB=libssp.so
cp /opt/gcc-${VER}/lib/$LIB.0.0.0 $DESTDIR/usr/lib/$LIB.0.0.0
ln -s /usr/lib/$LIB.0.0.0 $DESTDIR/usr/lib/$LIB.0
ln -s /usr/lib/$LIB.0.0.0 $DESTDIR/usr/lib/$LIB
cp /opt/gcc-${VER}/lib/amd64/$LIB.0.0.0 $DESTDIR/usr/lib/amd64/$LIB.0.0.0
ln -s /usr/lib/amd64/$LIB.0.0.0 $DESTDIR/usr/lib/amd64/$LIB.0
ln -s /usr/lib/amd64/$LIB.0.0.0 $DESTDIR/usr/lib/amd64/$LIB

make_package runtime.mog
clean_up
