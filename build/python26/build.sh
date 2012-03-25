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

PATH=/opt/gcc-4.6.2/bin:$PATH
export PATH
CC=gcc
CXX=g++

PROG=Python         # App name
VER=2.6.7           # App version
PVER=1              # Package Version
PKG=runtime/python-26 # Package name (without prefix)
SUMMARY="$PROG"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="developer/build/autoconf"
DEPENDS_IPS="system/library/gcc-4-runtime library/zlib library/libffi@3.0.10
	library/readline database/sqlite-3 compress/bzip2 library/libxml2
	library/ncurses library/security/openssl"

export CCSHARED="-fPIC"
CFLAGS="$CFLAGS -std=c99"
LDFLAGS32="-L/usr/gnu/lib -R/usr/gnu/lib"
LDFLAGS64="-L/usr/gnu/lib/amd64 -R/usr/gnu/lib/amd64"
CPPFLAGS="$CPPFLAGS -I/usr/include/ncurses -D_LARGEFILE64_SOURCE"
CPPFLAGS32="-I/usr/lib/libffi-3.0.10/include"
CPPFLAGS64="-I/usr/lib/amd64/libffi-3.0.10/include"
CONFIGURE_OPTS="--enable-shared
	--with-system-ffi
	ac_cv_opt_olimit_ok=no
	ac_cv_olimit_ok=no"

preprep_build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null || logerr "Cannot change to build directory"
    /usr/bin/autoheader || logerr "autoheaer failed"
    /usr/bin/autoconf || logerr "autoreconf failed"
    popd > /dev/null
}

post_config() {
    pushd $TMPDIR/$BUILDDIR > /dev/null || logerr "Cannot change to build directory"
    perl -pi -e 's/(^\#define _POSIX_C_SOURCE.*)/\/* $$1 *\//' pyconfig.h
    perl -pi -e 's/^(\#define _XOPEN_SOURCE.*)/\/* $$1 *\//' pyconfig.h
    perl -pi -e 's/^(\#define _XOPEN_SOURCE_EXTENDED.*)/\/* $$1 *\//' pyconfig.h
    popd > /dev/null
}

configure64() {
    logmsg "--- configure (64-bit)"
    CFLAGS="$CFLAGS $CFLAGS64" \
    CXXFLAGS="$CXXFLAGS $CXXFLAGS64" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS64" \
    LDFLAGS="$LDFLAGS $LDFLAGS64" \
    CC="$CC -m64" CXX=$CXX \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_64 \
    $CONFIGURE_OPTS || \
        logerr "--- Configure failed"
}

make_prog32() {
    post_config
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    logmsg "--- make"
    logcmd $MAKE $MAKE_JOBS DFLAGS=-32 || \
        logerr "--- Make failed"
}

make_prog64() {
    post_config
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    logmsg "--- make"
    logcmd $MAKE $MAKE_JOBS DFLAGS=-64 DESTSHARED=/usr/lib/python2.6/lib-dynload || \
        logerr "--- Make failed"
}

make_install32() {
    make_install
    rm $DESTDIR/usr/bin/i386/python || logerr "--- cannot remove arch hardlink"
    mv $DESTDIR/usr/lib/python2.6/config/Makefile $DESTDIR/usr/lib/python2.6/config/Makefile.32 || logerr "--- Makefile backup (32)"
}
make_install64() {
    logmsg "--- make install"
    logcmd $MAKE DESTDIR=${DESTDIR} install DESTSHARED=/usr/lib/python2.6/lib-dynload || \
        logerr "--- Make install failed"
    rm $DESTDIR/usr/bin/amd64/python || logerr "--- cannot remove arch hardlink"
    rm $DESTDIR/usr/lib/python2.6/config/libpython2.6.a || logerr "--- cannot remove static lib"
    (cd $DESTDIR/usr/bin && ln -s python2.6 python) ||  logerr "--- could not setup python softlink"
    mv $DESTDIR/usr/lib/python2.6/config/Makefile $DESTDIR/usr/lib/python2.6/config/Makefile.64 || logerr "--- Makefile backup (64)"
    mv $DESTDIR/usr/lib/python2.6/config/Makefile.32 $DESTDIR/usr/lib/python2.6/config/Makefile || logerr "--- Makefile restore (32)"
}

init
download_source $PROG $PROG $VER
patch_source
preprep_build
prep_build
build
make_isa_stub
strip_install -x
fix_permissions
make_package
clean_up
