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

PROG=Python
VER=3.4.3
VERHUMAN=$VER
PKG=omniti/runtime/python-34
SUMMARY="$PROG - An Interpreted, Interactive, Object-oriented, Extensible Programming Language."
DESC="$SUMMARY"

DEPENDS_IPS="system/library/gcc-4-runtime"

PREFIX=/opt/python34
BUILDARCH=64

CFLAGS="-O3"
CXXFLAGS="-O3"
CPPFLAGS="-D_REENTRANT"
#LDFLAGS64="$LDFLAGS64 -L/opt/python34/lib/$ISAPART64 -R/opt/python34/lib/$ISAPART64"

CONFIGURE_OPTS="--with-system-ffi
                --enable-shared
		"
CONFIGURE_OPTS_64="--prefix=$PREFIX
                   --sysconfdir=$PREFIX/etc
                   --includedir=$PREFIX/include
                   --bindir=$PREFIX/bin
                   --sbindir=$PREFIX/sbin
                   --libdir=$PREFIX/lib
                   --libexecdir=$PREFIX/libexec
                   "

build() {
    CC="$CC $CFLAGS $CFLAGS64" \
    CXX="$CXX $CXXFLAGS $CXXFLAGS64" \
    build64
    mv "$DESTDIR/$PREFIX/lib/python3.4/site-packages/setuptools/script template (dev).py" "$DESTDIR/$PREFIX/lib/python3.4/site-packages/setuptools/script_template_dev.py" 
    mv "$DESTDIR/$PREFIX/lib/python3.4/site-packages/setuptools/script template.py" "$DESTDIR/$PREFIX/lib/python3.4/site-packages/setuptools/script_template.py"
    mv "$DESTDIR/$PREFIX/lib/python3.4/site-packages/setuptools/command/launcher manifest.xml" "$DESTDIR/$PREFIX/lib/python3.4/site-packages/setuptools/command/launcher_manifest.xml"
    mv "$DESTDIR/$PREFIX/lib/python3.4/site-packages/setuptools/__pycache__/script template (dev).cpython-34.pyc" "$DESTDIR/$PREFIX/lib/python3.4/site-packages/setuptools/__pycache__/script_template_dev.cpython-34.pyc"
    mv "$DESTDIR/$PREFIX/lib/python3.4/site-packages/setuptools/__pycache__/script template.cpython-34.pyc" "$DESTDIR/$PREFIX/lib/python3.4/site-packages/setuptools/__pycache__/script_template.cpython-34.pyc"
}

save_function configure64 configure64_orig
configure64() {
    configure64_orig
    logmsg "--- Fixing pyconfig.h so _socket.so builds"
    perl -pi'*.orig' -e 's/#define (HAVE_NETPACKET_PACKET_H) 1/#undef \1/' \
        pyconfig.h || logerr "Failed to fix pyconfig.h"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up
