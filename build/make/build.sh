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
# this will build
#
#   * make
#   * sccs
#   * assorted bin-only bits: (from sub root)
#     * as
#     * libtdf
#     * libxprof
#     * libxprof_audit

# Load support functions
. ../../lib/functions.sh

PROG=make
VER=0.5.11
PKG=developer/build/make ##IGNORE##
SUMMARY="Omni-OS Bundled Development Tools"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="sunstudio12.1 compatibility/ucb"
DEPENDS_IPS="system/library SUNWcs system/library/math"

CONFIGURE_OPTS=""
PKGE=$(url_encode $PKG)
DESTDIR=$DTMPDIR/make_pkg

prebuild_clean() {
    logmsg "Cleaning destdir: $DESTDIR"
    logcmd rm -rf $DESTDIR
}

build() {
    logmsg "Building and installing ($1)"
    pushd $TMPDIR/$1/usr/src > /dev/null || logerr "can't enter build harness"
    logcmd env STUDIOBIN=/opt/sunstudio12.1/bin DESTDIR=$DESTDIR ./build ||
        logerr "make/install ($1) failed"
    popd > /dev/null
}

place_bins() {
    logmsg "Moving closed bins into place"
    (cd $SRCDIR/root && tar cf - .) | (cd $DESTDIR && tar xf -) ||
        logerr "Failed to copy closed bins"
}
move_and_links() {
    logmsg "Shifting binaries and setting up links"
    logcmd mv $DESTDIR/usr/ccs/bin/help $DESTDIR/usr/bin/sccshelp
    pushd $DESTDIR/usr/ccs/bin > /dev/null || logerr "Cannot chdir"
    for cmd in *
    do
        logcmd mv $cmd $DESTDIR/usr/bin/ || logerr "Cannot relocate /usr/ccs/bin/$cmd"
        logcmd ln -s ../../$cmd $cmd
    done
    logcmd ln -s ../../sccshelp $DESTDIR/usr/ccs/bin/sccshelp
    logcmd ln -s ../../sccshelp $DESTDIR/usr/ccs/bin/help
    popd > /dev/null
}

init

prebuild_clean

BUILDDIR=devpro-make-20061219
download_source devpro devpro-make src-20061219
build devpro-make-20061219

BUILDDIR=devpro-sccs-20061219
download_source devpro devpro-sccs src-20061219
build devpro-sccs-20061219

place_bins
move_and_links

make_package
clean_up
