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

PROG=jpeg
VER=8d
VERHUMAN=$VER
PKG=omniti/library/libjpeg
SUMMARY="$PROG - Free Library for JPEG Image Compression (v$VER)"
DESC="$SUMMARY"

CONFIGURE_OPTS="--enable-shared"

# Turn the letter component of the version into a number for IPS versioning
ord26() {
    local ASCII=$(printf '%d' "'$1")
    ASCII=$((ASCII - 64))
    [[ $ASCII -gt 32 ]] && ASCII=$((ASCII - 32))
    echo $ASCII
}

save_function make_package make_package_orig
make_package() {
    NUMVER=${VER::$((${#VER} -1))}
    ALPHAVER=${VER:$((${#VER} -1))}

    VER=${NUMVER}.$(ord26 ${ALPHAVER}) \
    make_package_orig
}

init
download_source $PROG jpegsrc.v${VER}
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
