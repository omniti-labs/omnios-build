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
# Copyright 2017 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=bind
VER=9.10.6
VERHUMAN=$VER
PKG=network/dns/bind
SUMMARY="BIND DNS tools"
DESC="$SUMMARY ($VER)"

DEPENDS_IPS="library/libxml2 library/security/openssl library/zlib
             system/library system/library/gcc-5-runtime system/library/math"

BUILDARCH=32

CONFIGURE_OPTS="
    --bindir=$PREFIX/sbin
    --sbindir=$PREFIX/sbin
    --libdir=$PREFIX/lib/dns
    --sysconfdir=/etc
    --localstatedir=/var
    --with-libtool
    --with-openssl
    --enable-threads=yes
    --enable-devpoll=yes
    --disable-openssl-version-check
    --enable-fixed-rrset
    --disable-getifaddrs
    --with-pkcs11
    --enable-shared
    --disable-static
"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
VER=${VER//-P/.}
VER=${VER//-W/.}
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
