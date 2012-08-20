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

PROG=iometer
VER=1.1.0-rc1
VERHUMAN=$VER
PKG=omniti/system/storage/iometer
SUMMARY="Iometer is an I/O subsystem measurement and characterization tool for single and clustered systems."
DESC="$SUMMARY"

BUILDARCH=64
NO_PARALLEL_MAKE=true

configure64() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Copying appropriate OS Makefile into place"
    logcmd cp Makefile-Solaris.i386 Makefile || \
        logerr "--- Failed to copy Makefile"
    popd > /dev/null
}

# There is no default make target in the Makefile
make_prog() {
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    logmsg "--- make"
    logcmd $MAKE $MAKE_JOBS all || \
        logerr "--- Make failed"
}

# Makefile does not provide an install target
make_install() {
    logmsg "--- make install"
    logcmd mkdir -p $DESTDIR$PREFIX/bin ||
        logerr "Failed to create destination directory"
    logcmd cp -p dynamo $DESTDIR$PREFIX/bin/ ||
        logerr "Failed to copy dynamo into place"
}

init
download_source $PROG $PROG ${VER}-src
patch_source
prep_build
# Everything is in src/
BUILDDIR=${PROG}-${VER}/src
build
make_isa_stub
# Prepare a usable version. Strip from the "-" onward
VER=${VER%%-*}
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
