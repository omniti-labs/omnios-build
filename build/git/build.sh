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
# Copyright 2011-2016 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
# Copyright (c) 2014 by Delphix. All rights reserved.
#
# Load support functions
. ../../lib/functions.sh

PROG=git
VER=2.14.4
PKG=developer/versioning/git
SUMMARY="$PROG - a free and open source, distributed version control system"
DESC="$SUMMARY"
MAKE=gmake


BUILD_DEPENDS_IPS="compatibility/ucb developer/build/autoconf developer/build/gnu-make"

DEPENDS_IPS="runtime/python-26 \
             web/curl \
             library/security/openssl@1.0.2 \
             library/zlib"

TAR=gtar

# For inet_ntop which isn't detected properly in the configure script
LDFLAGS="-lnsl"
CFLAGS64="$CFLAGS64 -I/usr/include/amd64"
CONFIGURE_OPTS="--without-tcltk
    --with-python=/usr/bin/python
    --with-curl=/usr
    --with-openssl=/usr"

save_function configure32 configure32_orig
configure32() {
    make_param configure
    configure32_orig
}

save_function configure64 configure64_orig
configure64() {
    make_param configure
    configure64_orig
}

install_man() {
    logmsg "Fetching and installing pre-built man pages"
    if [[ ! -f ${TMPDIR}/${PROG}-manpages-${VER}.tar.gz ]]; then
        pushd $TMPDIR > /dev/null
        get_resource $PROG/${PROG}-manpages-${VER}.tar.gz || \
            logerr "--- Failed to fetch tarball"
        popd > /dev/null
    fi
    logcmd mkdir -p ${DESTDIR}${PREFIX}/share/man
    pushd ${DESTDIR}${PREFIX}/share/man > /dev/null
    extract_archive ${TMPDIR}/${PROG}-manpages-${VER}.tar.gz || \
        logerr "--- Error extracting archive"
    popd > /dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
install_man
make_package
clean_up
