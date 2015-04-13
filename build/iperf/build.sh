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
# Copyright 2015 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=iperf
VER=3.0.11
VERHUMAN=$VER
PKG=network/test/iperf
SUMMARY="iperf network testing tool"
DESC="$SUMMARY $VER"

DEPENDS_IPS="system/library"

BUILDARCH=64

CONFIGURE_OPTS="--bindir=$PREFIX/bin"
LDFLAGS="-lsocket -lnsl"

make_symlinks()  {
	logcmd ln -s iperf3 $DESTDIR/usr/bin/iperf
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_symlinks
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
