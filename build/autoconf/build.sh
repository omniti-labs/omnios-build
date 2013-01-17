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

PROG=autoconf                 # App name
VER=2.69                      # App version
PKG=developer/build/autoconf  # Package name (without prefix)
SUMMARY="autoconf - GNU autoconf utility"
DESC="GNU autoconf - GNU autoconf utility ($VER)"

NO_PARALLEL_MAKE=1
BUILDARCH=32

DEPENDS_IPS="developer/macro/gnu-m4 runtime/perl"

CONFIGURE_OPTS="--infodir=$PREFIX/share/info --bindir=$PREFIX/bin"

make_sfw_links() {
    logmsg "Creating SFW symlinks"
    logcmd mkdir -p $DESTDIR/$PREFIX/sfw/bin
    pushd $DESTDIR/$PREFIX/sfw/bin > /dev/null
    for file in autoscan autoheader autom4te ifnames autoconf autoreconf autoupdate
        do logcmd ln -s ../../bin/$file $file || \
            logerr "Failed to create link for $file"
        done
    popd > /dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_sfw_links
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
