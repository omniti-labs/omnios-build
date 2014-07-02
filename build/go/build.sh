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
# Copyright 2014 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=go
VER=1.3
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=omniti/runtime/go
SUMMARY="An open source programming language."
DESC=$SUMMARY

make_clean() {
    cd $TMPDIR/$BUILDDIR/src
    logcmd ./clean.bash
    cd ..
}

configure64() {
    logcmd mkdir -p $DESTDIR/opt/omniti/lib/amd64 && \
    logcmd mkdir -p $DESTDIR/opt/omniti/bin/amd64 || \
    logerr "Failed to create Go install directory."
}

make_prog64() {
    logmsg "Making libraries (64)"
    cd src
    logcmd ./all.bash mflag=-m64 || logerr "build failed"
    cd ..
}

make_install64() {
    logmsg "Installing libraries (64)"
    logcmd mv $TMPDIR/$BUILDDIR/bin/* $DESTDIR/opt/omniti/bin/amd64 && \
    logcmd mv $TMPDIR/$BUILDDIR/lib/* $DESTDIR/opt/omniti/lib/amd64 || \
    logerr "Failed to install Go"
}

init
download_source $PROG $PROG $VER.src
patch_source
prep_build

make_clean
configure64
make_prog64
make_install64

make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
