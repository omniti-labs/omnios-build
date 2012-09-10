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

PROG=wackamole
VER=2.1.4
PKG=/omniti/network/wackamole
PROG=wackamole
VERHUMAN=$VER
SUMMARY="Manage IP failover"
DESC="Wackamole is an application that helps with making a cluster highly available. It manages a bunch of virtual IPs, that should be available to the outside world at all times."
reset_configure_opts
[[ "$BUILDARCH" == "both" ]] && BUILDARCH=32

LDFLAGS32="$LDFLAGS32 -L/opt/omni/lib -R/opt/omni/lib"
CFLAGS32="$CFLAGS32 -I/opt/omni/include"
LDFLAGS="$LDFLAGS -L/opt/omni/lib -R/opt/omni/lib"
CFLAGS="$CFLAGS -I/opt/omni/include"

BUILD_DEPENDS_IPS="/omniti/network/spread /developer/lexer/flex"

copy_manifest() {
    # SMF manifest
    logmsg "--- Copying SMF manifest"
    logcmd cp $SRCDIR/wackamole.xml ${DESTDIR}${PREFIX}/etc/wackamole.xml
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
