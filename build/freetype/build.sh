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

PROG=freetype
VER=2.4.8
VERHUMAN=$VER
PVER=0.1
PKG=system/library/freetype-2
SUMMARY="FreeType 2 font engine"
DESC="FreeType 2 font engine"

DEPENDS_IPS="library/zlib compress/bzip2 system/library system/library/gcc-4-runtime"

GNUMAKE=gmake
export GNUMAKE
CONFIGURE_OPTS="--with-zlib --with-pic --enable-biarch-config --disable-static"
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --includedir=/usr/include"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --includedir=/usr/include"

install_license() {
    for lic in LICENSE.TXT FTL.TXT GPLv2.TXT
    do
        cp $TMPDIR/$BUILDDIR/docs/$lic $DESTDIR/$lic
    done
}
init
download_source freetype2 $PROG $VER
patch_source
prep_build
build
install_license
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
