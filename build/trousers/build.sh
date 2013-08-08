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

PROG=trousers   # App name
VER=0.3.8       # App version
VERHUMAN=$VER   # Human-readable version
PKG=library/security/trousers  # Package name (without prefix)
SUMMARY="trousers - TCG Software Stack - software for accessing a TPM device"
DESC="$SUMMARY ($VER)"

BUILD_DEPENDS_IPS="developer/build/libtool developer/build/automake developer/build/autoconf"
DEPENDS_IPS="system/library/gcc-4-runtime library/security/openssl@1.0.1"

LIBS="-lbsm -lnsl -lsocket -lgen -lscf -lresolv"

preprep_build() {
  pushd $TMPDIR/$BUILDDIR > /dev/null || logerr "Cannot change to build directory"
  for f in `ls src/include/tss/*.h` ; do
    /usr/bin/dos2unix $f $f
  done
  for f in `ls src/include/trousers/*.h` ; do
    /usr/bin/dos2unix $f $f
  done
  for f in `ls src/include/*.h` ; do
    /usr/bin/dos2unix $f $f
  done
  logcmd libtoolize -f || logerr "libtoolize failed"
  logcmd aclocal || logerr "aclocal failed"
  logcmd automake --add-missing || logerr "automake --add-missing failed"
  logcmd automake src/tspi/Makefile || logerr "automake failed"
  logcmd autoreconf -vi 2>&1 > /dev/null
  logcmd autoreconf -vi || logerr "autoreconf failed"
  popd > /dev/null
}

cleanup_configure() {
    for makefile in src/trspi/Makefile src/tspi/Makefile; do
        mv $makefile $makefile.unneeded
        cat $makefile.unneeded | sed -e 's/LIBS = .*/LIBS = -lnsl -lsocket -lgen/;' > $makefile
    done
}

configure32() {
    logmsg "--- configure (32-bit)"
    CFLAGS="$CFLAGS $CFLAGS32" \
    CXXFLAGS="$CXXFLAGS $CXXFLAGS32" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS32" \
    LDFLAGS="$LDFLAGS $LDFLAGS32" \
    CC=$CC CXX=$CXX \
    LIBS="$LIBS" \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_32 \
    $CONFIGURE_OPTS || \
        logerr "--- Configure failed"
    cleanup_configure
}

configure64() {
    logmsg "--- configure (64-bit)"
    CFLAGS="$CFLAGS $CFLAGS64" \
    CXXFLAGS="$CXXFLAGS $CXXFLAGS64" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS64" \
    LDFLAGS="$LDFLAGS $LDFLAGS64" \
    CC=$CC CXX=$CXX \
    LIBS="$LIBS" \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_64 \
    $CONFIGURE_OPTS || \
        logerr "--- Configure failed"
    cleanup_configure
}

install_license() {
    cp $TMPDIR/$BUILDDIR/LICENSE $DESTDIR/license
}

init
download_source $PROG $PROG $VER
patch_source
preprep_build
prep_build
build
make_isa_stub
install_license
make_package
clean_up
