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

PROG=libxml2        # App name
VER=2.9.1           # App version
PKG=library/libxml2 # Package name (without prefix)
SUMMARY="$PROG - XML C parser and toolkit"
DESC="$SUMMARY"

DEPENDS_IPS="compress/xz@5.0 system/library/gcc-5-runtime library/zlib@1.2.8"
BUILD_DEPENDS_IPS="$DEPENDS_IPS developer/sunstudio12.1"

fix_python_install() {
    logcmd mkdir -p $DESTDIR/usr/lib/python2.6/vendor-packages
    logcmd mv $DESTDIR/usr/lib/python2.6/site-packages/* $DESTDIR/usr/lib/python2.6/vendor-packages/ || logerr "failed relocating python install"
    logcmd rm -f $DESTDIR/usr/lib/python2.6/vendor-packages/64/drv_libxml2.py
    logcmd rm -rf $DESTDIR/usr/lib/python2.6/site-packages || logerr "failed removing bad python install"
    logcmd rm -rf $DESTDIR/usr/include/amd64 || logerr "failed removing bad includes install"
}

install_license(){
    logcmd cp $TMPDIR/$BUILDDIR/COPYING $DESTDIR/license
}

make_prog64() {
    logcmd perl -pi -e 's#(\$CC.*\$compiler_flags)#$1 -nostdlib#g;' libtool ||
        logerr "libtool patch failed"
    logcmd gmake || logerr "Make failed"
}

make_prog32() {
    logcmd perl -pi -e 's#(\$CC.*\$compiler_flags)#$1 -nostdlib#g;' libtool ||
        logerr "libtool patch failed"
    logcmd gmake || logerr "Make failed"
}

make_install64() {
    logmsg "--- make install"
    logcmd perl -pi -e 's#(\/site-packages)#$1\/64#g;' python/.libs/libxml2mod.la ||
        logerr "libtool libxml2mod.la patch failed"
    logcmd perl -pi -e 's#(\/site-packages)#$1\/64#g;' python/libxml2mod.la ||
        logerr "libtool libxml2mod.la patch failed"

    logcmd perl -pi -e 's#(\/site-packages)#$1\/64#g;' python/.libs/libxml2mod.lai ||
        logerr "libtool libxml2mod.la patch failed"

    logcmd $MAKE DESTDIR=${DESTDIR} \
        PYTHON_SITE_PACKAGES=/usr/lib/python2.6/site-packages/64 \
        install || \
        logerr "--- Make install failed"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_lintlibs xml2 /usr/lib /usr/include/libxml2 "libxml/*.h"
fix_python_install
make_isa_stub
install_license
make_package
clean_up
