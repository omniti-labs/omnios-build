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

PROG=vim        # App name
VER=7.3         # App version
PVER=1          # Package Version
PKG=editor/vim  # Package name (without prefix)
SUMMARY="Vi IMproved"
DESC="$SUMMARY version $VER"

BUILDDIR=${PROG}${VER/./}     # Location of extracted source
BUILDARCH=32

DEPENDS_IPS="system/extended-system-utilities system/library system/library/math"

# We're only shipping 32-bit so forgo isaexec
CONFIGURE_OPTS="
    --bindir=$PREFIX/bin
    --with-features=huge
    --without-x
    --disable-gui
    --disable-gtktest
"
reset_configure_opts

# The build doesn't supply a 'vi' symlink so we make one
link_vi() {
    logmsg "Creating symlink for $PREFIX/bin/vi"
    logcmd ln -s vim $DESTDIR$PREFIX/bin/vi
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
link_vi
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
