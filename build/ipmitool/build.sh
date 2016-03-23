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

PROG=ipmitool
VER=1.8.16
VERHUMAN=$VER
PKG=system/management/ipmitool
SUMMARY="IPMI management tool"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="driver/ipmi"

BUILDARCH=32
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --bindir=/usr/sbin --sbindir=/usr/lib"
CONFIGURE_OPTS="$CONFIGURE_OPTS --mandir=/usr/share/man
	--enable-intf-free=yes
	--enable-intf-usb=no
	--enable-solaris-opt"

install_smf(){
    logcmd mkdir -p $DESTDIR/lib/svc/manifest/network
    logcmd mkdir -p $DESTDIR/lib/svc/method
    logcmd cp $SRCDIR/files/ipmievd.xml $DESTDIR/lib/svc/manifest/network/ipmievd.xml
    logcmd cp $SRCDIR/files/svc-ipmievd $DESTDIR/lib/svc/method/svc-ipmievd
}

auto_reconf() {
	# This package doesn't like aclocal 1.15.  Fix it!
	pushd $TMPDIR/$BUILDDIR
	autoreconf -fi
	popd
}

init
download_source $PROG $PROG $VER
patch_source
auto_reconf
prep_build
run_autoconf
build
install_smf
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
