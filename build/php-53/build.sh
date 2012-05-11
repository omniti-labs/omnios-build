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

PROG=php        # App name
VER=5.3.13      # App version
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=omniti/runtime/$PROG-${VER//./}            # Package name (e.g. library/foo)
SUMMARY="PHP 5.3 64 bit build"      # One-liner, must be filled in
DESC="PHP is a widely-used general-purpose scripting language that is especially suited for Web development and can be embedded into HTML."         # Longer description, must be filled in

BUILD_DEPENDS_IPS="omniti/server/apache22"
DEPENDS_IPS="web/curl 
            omniti/library/freetype2
            omniti/library/gd  
            omniti/library/libjpeg
            system/library/iconv/unicode
            system/library/iconv/utf-8
            system/library/iconv/utf-8/manual
            system/library/iconv/xsh4/latin
            omniti/library/libpng
            omniti/library/libpq5
            omniti/library/libssh2
            library/libxml2
            omniti/database/mysql-55/library
            database/sqlite-3
            library/libxslt
            library/libtool/libltdl
            omniti/library/mhash
            omniti/library/libmcrypt"


PREFIX=/opt/${PROG}-${VER//./} # Install to its own prefix
reset_configure_opts # We changed prefix, we reset configure_opts

# Php will be compiled once for each of the following options
APXS_OPTS="--with-apxs2=/opt/apache22/bin/apxs"

FREETYPE_PATH="/opt/omni"

CFLAGS="-O2 -I/opt/omni/include"
LDFLAGS64="$LDFLAGS64 -L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64 \
    -L/opt/omni/lib/$ISAPART64/mysql -R/opt/omni/lib/$ISAPART64/mysql \
    -L$PREFIX/lib/$ISAPART64 -R$PREFIX/lib/$ISAPART64"

# The contents of this variable get passed to configure later on with the
# apache apxs stuff added in
PHP_CONFIGURE_OPTS="
        --with-pear=$PREFIX/lib/php
        --with-gd
        --with-jpeg-dir=/opt/omni
        --with-png-dir=/opt/omni
        --with-freetype-dir=$FREETYPE_PATH
        --with-zlib
        --enable-pdo
        --with-mysql=/opt/omni
        --with-pdo_sqlite
        --with-pdo-mysql=/opt/omni
        --with-pdo-pgsql=/opt/omni
        --with-pgsql=/opt/omni
        --with-bz2=/opt/omni
        --with-curl=/opt/omni
        --with-ldap=/usr
        --with-ldap-sasl=no
        --with-mhash=/opt/omni
        --with-mcrypt=/opt/omni
        --enable-soap
        --with-iconv
        --with-xsl=/opt/omni
        --enable-exif
        --enable-bcmath
        --enable-calendar
        --enable-ftp
        --enable-mbstring
        --enable-sockets
        --with-gettext
        --with-sqlite
        --enable-pcntl
        $PHPOPT"

CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64
        --with-libdir=lib/$ISAPART64
        --includedir=$PREFIX/include/$ISAPART64
        --with-mysqli=/opt/omni/bin/$ISAPART64/mysql_config"

# We need to make a fake httpd.conf so apxs in make install
make_httpd_conf() {
    logmsg "Generating fake httpd.conf file"
    mkdir -p $DESTDIR/opt/apache22/conf
    echo -e "\n\n\nLoadModule access_module modules/mod_access.so\n\n\n" > \
        $DESTDIR/opt/apache22/conf/httpd.event.conf
}

# And a function to remove the temporary httpd.conf files
remove_httpd_conf() {
    logmsg "Removing Generated httpd.conf file"
    rm -rf $DESTDIR/opt/apache22/conf ||
        logerr "Failed to remove apache22 config"
}

# We need to do some custom steps as part of the build
build() {
    make_httpd_conf
    CONFIGURE_OPTS="$APXS_OPTS $PHP_CONFIGURE_OPTS"
    build64
    remove_httpd_conf
}

make_install() {
    logmsg "--- make install"
    logcmd $MAKE DESTDIR=${DESTDIR} INSTALL_ROOT=${DESTDIR} install || \
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
