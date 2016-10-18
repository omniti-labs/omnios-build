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
# Copyright 2016 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=readline
VER=7.0
VERHUMAN=$VER
PKG=library/readline
SUMMARY="GNU readline"
DESC="GNU readline library ($VER)"

DEPENDS_IPS="system/library system/library/gcc-5-runtime"

CONFIGURE_OPTS="--disable-static"

fix_permissions() {
    logmsg "--- Making shared libs executable"
    for file in libhistory libreadline; do
        logcmd chmod 0555 $DESTDIR$PREFIX/lib/${file}.so.*
        logcmd chmod 0555 $DESTDIR$PREFIX/lib/$ISAPART64/${file}.so.*
    done
}

make_prog() {
    logcmd gmake SHOBJ_LDFLAGS='-shared -Wl,-i -Wl,-h,$@ -nostdlib -lc' || \
        logerr "--- Make failed"
}

copy_version6() {
    # Keep the r151018 version 6.3 library around for older apps.
    # On the off chance we do non-x86/amd64 architectures, this'll get more
    # complicated.
    logcmd cp $SRCDIR/files/libreadline.so.6 $SRCDIR/files/libhistory.so.6 \
	$DESTDIR$PREFIX/lib/. || logerr "--- Copying of v6.3 libraries failed"
    logcmd cp $SRCDIR/files/amd64/libreadline.so.6 \
	$SRCDIR/files/amd64/libhistory.so.6 $DESTDIR$PREFIX/lib/$ISAPART64/. \
	|| logerr "--- Copying of 64-bit v6.3 libraries failed"
}


init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
copy_version6
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
