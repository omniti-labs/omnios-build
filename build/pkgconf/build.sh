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
# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=pkgconf
VER=0.9.3
VERHUMAN=$VER
PKG=omniti/library/pkgconf
SUMMARY="pkgconf is a modern replacement for pkg-config"
DESC="pkgconf is a program which helps to configure compiler and linker flags for development frameworks. It is similar to pkg-config, but was written from scratch in the summer of 2011 to replace pkg-config, which now needs itself to build itself (or you can set a bunch of environment variables, both are pretty ugly)."
TAR=gtar

symlink_pkg_config() {
    logmsg "Creating pkg-config compat symlink"
    logcmd /bin/ln -sf ${PREFIX}/bin/pkgconf ${DESTDIR}${PREFIX}/bin/pkg-config
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
symlink_pkg_config
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
