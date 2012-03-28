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

PROG=gzip
VER=1.4
VERHUMAN=$VER
PKG=compress/gzip
SUMMARY="The GNU Zip (gzip) compression utility"
DESC="$SUMMARY $VER"

CONFIGURE_OPTS="--bindir=/usr/bin --infodir=/usr/sfw/share/info"
BUILDARCH=32

# Solaris renames the z* utilities to gz* so we have to update the docs
rename_in_docs() {
    logmsg "Renaming z->gz references in documentation"
    pushd $TMPDIR/$BUILDDIR > /dev/null
    for file in `ls *.1 *.info z*.in` ; do
        logcmd mv $file $file.tmp
        logmsg "Running: sed -f $SRCDIR/renaming.sed $file.tmp > $file"
        sed -f $SRCDIR/renaming.sed $file.tmp > $file
        logcmd rm -f $file.tmp
    done
    popd > /dev/null
}

# Renames z* binaries and man pages to gz* in the DESTDIR
rename_files() {
    logmsg "Renaming z->gz files in $DESTDIR"
    for dir in $DESTDIR$PREFIX/bin $DESTDIR$PREFIX/share/man/man1; do
        pushd $dir
        for zfile in `ls z*`; do
            logcmd mv $zfile g$zfile
        done
        popd > /dev/null
    done
}

build32() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 32-bit"
    export ISALIST="$ISAPART"
    make_clean
    configure32
    make_prog32
    rename_in_docs
    make_install32
    rename_files
    popd > /dev/null
    unset ISALIST
    export ISALIST
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
