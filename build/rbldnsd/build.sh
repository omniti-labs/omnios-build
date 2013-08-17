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

PROG=rbldnsd
VER="0.997a"
VERHUMAN=$VER
PKG=omniti/network/rbldnsd
SUMMARY="rbldnsd is a small and fast DNS daemon which is especially made to serve DNSBL zones."
DESC=$SUMMARY

# Custom ./configure that doesn't recognize any GNU options
CONFIGURE_OPTS=""
CONFIGURE_OPTS_64=""
CONFIGURE_OPTS_32=""

# Custom ./configure that generates a custom Makefile that doesn't
# recognize 'make install' (mercifully we only care about one file)

make_install32() {
  logcmd mkdir -p $DESTDIR/opt/omni/sbin
  logcmd cp $TMPDIR/$BUILDDIR/rbldnsd $DESTDIR/opt/omni/sbin
}

make_install64() {
  logcmd mkdir -p $DESTDIR/opt/omni/sbin
  logcmd cp $TMPDIR/$BUILDDIR/rbldnsd $DESTDIR/opt/omni/sbin
}

# Turn the letter component of the version into a number for IPS
versioning
ord26() {
    local ASCII=$(printf '%d' "'$1")
    ASCII=$((ASCII - 64))
    [[ $ASCII -gt 32 ]] && ASCII=$((ASCII - 32))
    echo $ASCII
}
save_function make_package make_package_orig
make_package() {
    if [[ -n "`echo $VER | grep [a-z]`" ]]; then
        NUMVER=${VER::$((${#VER} -1))}
        ALPHAVER=${VER:$((${#VER} -1))}
        VER=${NUMVER}.$(ord26 ${ALPHAVER})
    fi

    make_package_orig
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
