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

PROG=mysql
VER=5.5.23
VERHUMAN=$VER

BUILD_DEPENDS_IPS="omniti/developer/build/cmake"
DEPENDS_IPS="system/library/g++-4-runtime system/library/gcc-4-runtime"

case $FLAVOR in
    ""|default)
        # Default - build full server, 64-bit only
        PKG=omniti/database/mysql-55
        SUMMARY="MySQL Community Edition open source database (server)"
        DESC="$SUMMARY"
        BUILDARCH=64
        PREFIX=/opt/mysql55
        CONFIGURE_OPTS_64=""
        LOCAL_MOG_FILE=$SRCDIR/server.mog
    ;;
    libs)
        # For use with external programs - dual-arch, lives in /opt/omni
        PKG=omniti/database/mysql-55/library
        SUMMARY="MySQL Community Edition open source database (client and libraries)"
        DESC="$SUMMARY"
        PREFIX=/opt/omni
        CONFIGURE_OPTS_32="-DINSTALL_BINDIR=bin/$ISAPART
                           -DINSTALL_SBINDIR=sbin/$ISAPART
                           -DINSTALL_INCLUDEDIR=include/mysql"
        CONFIGURE_OPTS_64="-DINSTALL_BINDIR=bin/$ISAPART64
                           -DINSTALL_SBINDIR=sbin/$ISAPART64
                           -DINSTALL_LIBDIR=lib/$ISAPART64
                           -DINSTALL_INCLUDEDIR=include/mysql"
        LOCAL_MOG_FILE=$SRCDIR/libs.mog
    ;;
esac

# Generic options for all flavors
CPPFLAGS="-D__EXTENSIONS__"
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

prune_for_libs() {
    # For libs flavor we just want the bare essentials and this is easier done here than via pkgmogrify
    logmsg "Pruning destination directory"
    pushd $DESTDIR$PREFIX > /dev/null
    logcmd rm COPYING INSTALL-BINARY README
    for file in `cat $SRCDIR/bins_to_prune`; do
        logcmd rm bin/$file bin/$ISAPART/$file bin/$ISAPART64/$file
    done
    logcmd rm -rf data docs lib/plugin man mysql-test sbin scripts sql-bench support-files
    popd > /dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
if [[ "$FLAVOR" == "libs" ]]; then
    prune_for_libs
fi
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
