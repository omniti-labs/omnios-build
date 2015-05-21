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

PROG=unixODBC
VER=2.3.2
VERHUMAN=$VER
PKG=library/unixodbc
SUMMARY="The UnixODBC Subsystem and SDK"
DESC="UnixODBC - The UnixODBC Subsystem and SDK ($VER)"

DEPENDS_IPS="system/library system/library/math system/library/gcc-5-runtime"

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

save_function make_prog64 make_prog64_orig
save_function make_prog32 make_prog32_orig
make_prog64() {
    logcmd perl -pi -e 's#(\$CC.*\$compiler_flags)#$1 -nostdlib#g;' libtool ||
        logerr "libtool patch failed"
    make_prog64_orig
}
make_prog32() {
    logcmd perl -pi -e 's#(\$CC.*\$compiler_flags)#$1 -nostdlib#g;' libtool ||
        logerr "libtool patch failed"
    make_prog32_orig
}


init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
