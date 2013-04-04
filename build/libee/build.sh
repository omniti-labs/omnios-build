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

PROG=libee
VER=0.4.1
VERHUMAN=$VER
PKG=omniti/library/libee
SUMMARY="An Event Expression Library inspired by CEE"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="omniti/library/libestr"
DEPENDS_IPS="omniti/library/libestr"

CFLAGS="-I/opt/omni/include"
LDFLAGS32="-L/opt/omni/lib -R/opt/omni/lib"
LDFLAGS64="-L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64"
LIBESTR_CFLAGS="$CFLAGS"
export LIBESTR_CFLAGS

NO_PARALLEL_MAKE=true

save_function build32 build32_orig
save_function build64 build64_orig
build32() {
    LIBESTR_LIBS="$LDFLAGS32 -lestr"
    export LIBESTR_LIBS
    build32_orig
    unset LIBESTR_LIBS
}
build64() {
    LIBESTR_LIBS="$LDFLAGS64 -lestr"
    export LIBESTR_LIBS
    build64_orig
    unset LIBESTR_LIBS
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
