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

PROG=nginx
VER=1.4.1
VERHUMAN=$VER
PKG=omniti/server/nginx
SUMMARY="nginx web server"
DESC="nginx is a high-performance HTTP(S) server and reverse proxy"
PREFIX=/opt/nginx
BUILD_DEPENDS_IPS="library/security/openssl library/pcre"
DEPENDS_IPS=$BUILD_DEPENDS_IPS
BUILDARCH=64
CONFIGURE_OPTS_64=" \
    --with-ipv6 \
    --with-http_ssl_module \
    --with-http_addition_module  \
    --with-http_xslt_module \
    --with-http_flv_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --prefix=$PREFIX \
"
LDFLAGS64="$LDFLAGS64 -L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64"
CFLAGS64="$CFLAGS64"

add_extra_files() {
    logmsg "--- Copying SMF manifest"
    logcmd mkdir -p ${DESTDIR}/lib/svc/manifest/network
    logcmd cp $SRCDIR/files/http-nginx.xml ${DESTDIR}/lib/svc/manifest/network
    logcmd mkdir -p ${DESTDIR}/lib/svc/method/
    logcmd cp $SRCDIR/files/http-nginx ${DESTDIR}/lib/svc/method
    logmsg "Installing custom files and scripts"
    logcmd mv $DESTDIR$PREFIX/conf/nginx.conf $DESTDIR$PREFIX/conf/nginx.conf.dist
}

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
