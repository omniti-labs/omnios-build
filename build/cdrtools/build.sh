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

PROG=cdrtools
VER=3.00
VERHUMAN=$VER
PKG=media/cdrtools
SUMMARY="CD creation utilities"
DESC="$SUMMARY ($VER)"

DEPENDS_IPS="system/library system/library/gcc-4-runtime"

MAKE="make"
BUILDARCH=32

# cdrtools doesn't use configure, just make
make_clean() {
    true
}
configure32() {
    true
}
make_install() {
    mkdir -p $DESTDIR/etc/security/exec_attr.d
    mkdir -p $DESTDIR/usr/bin
    mkdir -p $DESTDIR/usr/share/man/man1
    cp $SRCDIR/files/exec_attr $DESTDIR/etc/security/exec_attr.d
    cp $TMPDIR/$BUILDDIR/mkisofs/OBJ/i386-sunos5-gcc/mkisofs $DESTDIR/usr/bin/mkisofs
    mkdir -p $DESTDIR/usr/share/man/man8
    cp $TMPDIR/$BUILDDIR/mkisofs/mkisofs.8 $DESTDIR/usr/share/man/man8/mkisofs.8
    for cmd in cdda2wav cdrecord readcd ; do
        cp $SRCDIR/files/$cmd $DESTDIR/usr/bin/$cmd
        cp $TMPDIR/$BUILDDIR/$cmd/OBJ/i386-sunos5-gcc/$cmd $DESTDIR/usr/bin/$cmd.bin
        cp $TMPDIR/$BUILDDIR/$cmd/$cmd.1 $DESTDIR/usr/share/man/man1/$cmd.1
    done
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
