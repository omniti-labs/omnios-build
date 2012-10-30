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

PROG=libgcc_s
VER=4.7.2
VERHUMAN=$VER
PKG=system/library/gcc-4-runtime
SUMMARY="gcc 4.7 runtime"
DESC="$SUMMARY"

PATH=/opt/gcc-${VER}/bin:$PATH
export LD_LIBRARY_PATH=/opt/gcc-{$VER}/lib

BUILD_DEPENDS_IPS="gcc47"
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
cp /opt/gcc-${VER}/lib/libgcc_s.so.1 $DESTDIR/usr/lib/libgcc_s.so.1
ln -s /usr/lib/libgcc_s.so.1 $DESTDIR/usr/lib/libgcc_s.so
mkdir -p $DESTDIR/usr/lib/amd64
cp /opt/gcc-${VER}/lib/amd64/libgcc_s.so.1 $DESTDIR/usr/lib/amd64/libgcc_s.so.1
ln -s /usr/lib/amd64/libgcc_s.so.1 $DESTDIR/usr/lib/amd64/libgcc_s.so
make_package runtime.mog
clean_up
