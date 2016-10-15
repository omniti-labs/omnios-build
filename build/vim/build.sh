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

# Patches are obtained from ftp://ftp.vim.org/pub/vim/patches/8.0/
# To update, append each patch to patches/all-patches and set the
# PATCHLEVEL variable below to match the number of the most recent
# patch, removing any zero padding.
#
# NOTE:  Patches 0001 and 0002 were included in the tarball afterwards.  Do
# not apply those.  Also, patch 0014 is severely broken, so we built it by hand
# and patches subsequent to 0014 should be put in patches/rest-of-patches.

PROG=vim
VER=8.0
PATCHLEVEL=41
PKG=editor/vim
SUMMARY="Vi IMproved"
DESC="$SUMMARY version $VER"

BUILDDIR=${PROG}${VER/./}     # Location of extracted source
BUILDARCH=32

DEPENDS_IPS="system/extended-system-utilities system/library system/library/math"

# VIM 8.0 source exposes either a bug in illumos msgfmt(1), OR it contains
# a GNU-ism we are strict about.  Either way, use GNU msgfmt for now.
export MSGFMT=/usr/gnu/bin/msgfmt

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
VER=${VER}.${PATCHLEVEL}
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
