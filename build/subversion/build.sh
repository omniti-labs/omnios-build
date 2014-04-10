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

PROG=subversion
VER=1.8.8
VERHUMAN=$VER
PKG=omniti/developer/versioning/subversion
SUMMARY="$PROG - An Open-Source Revision Control System"
DESC="$SUMMARY"

#NEON=neon
#NVER=0.29.0

DEPENDS_IPS="database/sqlite-3@3.8 library/security/openssl@1.0.1 
             omniti/library/apr@1.4 omniti/library/apr-util@1.4
             library/expat library/zlib system/library/gcc-4-runtime
             omniti/library/serf"
BUILD_DEPENDS_IPS="$DEPENDS_IPS developer/swig omniti/server/apache22"

CFLAGS32="-D__EXTENSIONS__ -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE"
CPPFLAGS32="-D__EXTENSIONS__ -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE"

CONFIGURE_OPTS="$CONFIGURE_OPTS
    --sysconfdir=$PREFIX/etc
    --with-pic
    --with-serf=/opt/omni
    --with-openssl
    --without-berkeley-db
    --without-jdk
    --disable-nls"

CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32
    --with-apr=/opt/omni/bin/$ISAPART/apr-1-config
    --with-apr-util=/opt/omni/bin/$ISAPART/apu-1-config"

CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64
    --with-swig=/opt/omni/bin/$ISAPART64/swig
    --with-apr=/opt/omni/bin/$ISAPART64/apr-1-config
    --with-apr-util=/opt/omni/bin/$ISAPART64/apu-1-config"

CPPFLAGS64="-D__EXTENSIONS__ -I/opt/omni/include/amd64"
CPPFLAGS="$CPPFLAGS -I/opt/omni/include" 

LDFLAGS32="$LDFLAGS32 \
    -L/opt/omni/lib -R/opt/omni/lib"

LDFLAGS64="$LDFLAGS64 \
    -L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64"

# Extra script/file installs
add_file() {
    logmsg "--- $1"
    logcmd mkdir -p $DESTDIR$PREFIX/`dirname $2`
    logcmd cp $SRCDIR/$1 $DESTDIR$PREFIX/$2 || \
        logerr "Failed to copy $1 to $2"
    if [[ -n "$3" ]]; then
        logcmd chmod $3 $DESTDIR$PREFIX/$2
    else
        logcmd chmod 0444 $DESTDIR$PREFIX/$2
    fi
}

add_extra_files() {
    logmsg "Installing custom files"
    add_file cacert.pem etc/subversion/cacert.pem
    add_file servers etc/subversion/servers
}

#save_function download_source download_source_orig
#download_source() {
#    BUILDDIR=${NEON}-${NVER}
#    download_source_orig $NEON $NEON $NVER
#    BUILDDIR=${PROG}-${VER}
#    download_source_orig $1 $2 $3
#    logmsg "Copying neon to subversion source directory"
#    logcmd cp -r ${TMPDIR}/${NEON}-${NVER} ${TMPDIR}/${PROG}-${VER}/neon || \
#        logerr "Failed to copy neon"
#}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
add_extra_files
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
