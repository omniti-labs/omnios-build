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

PROG=pciutils
VER=3.2.0
VERHUMAN=$VER
PKG=system/pciutils
SUMMARY="Programs (lspci, setpci) for inspecting and manipulating configuration of PCI devices"
DESC="$SUMMARY"

DEPENDS_IPS="system/pciutils/pci.ids@2.2"

BUILDARCH=32
NO_PARALLEL_MAKE=1

export PATH=/usr/gnu/bin:$PATH

configure32() {
    export CC PREFIX
}

make_prog() {
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    if [[ -n $LIBTOOL_NOSTDLIB ]]; then
        libtool_nostdlib $LIBTOOL_NOSTDLIB $LIBTOOL_NOSTDLIB_EXTRAS
    fi
    logmsg "--- make"
    logcmd $MAKE $MAKE_JOBS OPT="-O2 -DBYTE_ORDER=1234 -DLITTLE_ENDIAN=1234" || \
        logerr "--- Make failed"
}

make_install() {
    logmsg "--- make install"
    logcmd $MAKE DESTDIR=${DESTDIR} PREFIX=$PREFIX install || \
        logerr "--- Make install failed"
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
