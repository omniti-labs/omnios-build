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

PROG=pcre
VER=8.31
VERHUMAN=$VER
PKG=library/pcre
SUMMARY="Perl-Compatible Regular Expressions"
DESC="PCRE - Perl-Compatible Regular Expressions (8.30)"

DEPENDS_IPS="library/readline compress/bzip2 library/zlib system/library/g++-4-runtime
	system/library/gcc-4-runtime system/library system/library/math"

CONFIGURE_OPTS="$CONFIGURE_OPTS
	--includedir=/usr/include/pcre
	--localstatedir=/var
	--disable-static
	--enable-cpp
	--enable-rebuild-chartables
	--enable-utf8
	--enable-unicode-properties
	--enable-newline-is-any
	--disable-stack-for-recursion
	--enable-pcregrep-libz
	--enable-pcregrep-libbz2
	--with-posix-malloc-threshold=20
	--with-link-size=4
	--with-match-limit=10000000
	--with-pic
"

make_install64() {
    # the 32bit version installed these and the 64bit version will fail
    # reinstalling them... clear them out and let 64bit do its business.
    rm -rf $DESTDIR/usr/share/man
    make_install
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
