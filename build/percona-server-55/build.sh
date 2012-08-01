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

PROG=Percona-Server
VER=5.5.25a
RELEASE="rel27.1"
VERHUMAN=$VER-$RELEASE
PKG=omniti/database/percona-server-55
SUMMARY="Percona Server is an enhanced drop-in replacement for MySQL."
DESC="Percona Server offers breakthrough performance, scalability, features, and instrumentation."

BUILD_DEPENDS_IPS="developer/parser/bison omniti/developer/build/cmake system/library/g++-4-runtime system/library/gcc-4-runtime"
DEPENDS_IPS="system/library/g++-4-runtime system/library/gcc-4-runtime"

BUILDDIR=${PROG}-${VER}-${RELEASE}
BUILDARCH=64
NO_PARALLEL_MAKE=true
PREFIX=/opt/percona

CPPFLAGS="-D__EXTENSIONS__"
# We don't use autoconf defaults, so blank out 64-bit
CONFIGURE_OPTS_64=""
CONFIGURE_OPTS="-DCMAKE_INSTALL_PREFIX=$PREFIX
                -DBUILD_CONFIG=mysql_release
                -DHAVE_FAKE_PAUSE_INSTRUCTION=1
                -DHAVE_PAUSE_INSTRUCTION=0"
CONFIGURE_CMD="/opt/omni/bin/cmake ."

make_clean() {
    # Cmake doesn't have a distclean, so we just spike the cache file
    logmsg "--- make clean"
    logcmd $MAKE clean
    logcmd rm CMakeCache.txt
}

# Turn the letter component of the version into a number for IPS versioning
ord26() {
    local ASCII=$(printf '%d' "'$1")    ASCII=$((ASCII - 64))
    [[ $ASCII -gt 32 ]] && ASCII=$((ASCII - 32))
    echo $ASCII
}

save_function make_package make_package_orig
make_package() {
    # Remove the "rel" first
    RELEASE=${RELEASE//rel/}
    if [[ -n "`echo $VER | grep [a-z]`" ]]; then
        NUMVER=${VER::$((${#VER} -1))}
        ALPHAVER=${VER:$((${#VER} -1))}
        VER=${NUMVER}.$(ord26 ${ALPHAVER})
    fi
    # Stick it all together
    VER=${VER}.${RELEASE}
    make_package_orig
}

init
download_source $PROG $PROG $VER-$RELEASE
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
