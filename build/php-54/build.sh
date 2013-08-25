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

PROG=php
VER=5.4.19
VERHUMAN=$VER
PKG=omniti/runtime/php-54
SUMMARY="PHP Server 5.4"
DESC="PHP is a widely-used general-purpose scripting language that is especially suited for Web development and can be embedded into HTML."

BUILD_DEPENDS_IPS="compress/bzip2 database/sqlite-3 library/libtool/libltdl library/libxml2 library/libxslt system/library/iconv/unicode system/library/iconv/utf-8 system/library/iconv/utf-8/manual system/library/iconv/xsh4/latin web/curl omniti/database/mysql-55/library omniti/library/freetype2 omniti/library/gd  omniti/library/libjpeg omniti/library/libmcrypt omniti/library/libpng omniti/library/libpq5 omniti/library/libssh2 omniti/library/mhash omniti/server/apache22"
# Mostly auto-generated; these are additional
DEPENDS_IPS="database/sqlite-3 system/library/iconv/unicode system/library/iconv/utf-8 system/library/iconv/xsh4/latin omniti/library/gd omniti/library/libssh2 omniti/library/mhash"

# Though not strictly needed since we override build(), still nice to set
BUILDARCH=64
PREFIX=/opt/php54
reset_configure_opts

APXS_OPTS="--with-apxs2=/opt/apache22/bin/apxs"
FREETYPE_PATH="/opt/omni"

CFLAGS="-O2 -I/opt/omni/include"
LDFLAGS64="$LDFLAGS64 -L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64 \
    -L/opt/omni/lib/$ISAPART64/mysql -R/opt/omni/lib/$ISAPART64/mysql \
    -L$PREFIX/lib -R$PREFIX/lib"

# The contents of this variable get passed to configure later on with the
# apache apxs stuff added in
PHP_CONFIGURE_OPTS="
        --prefix=$PREFIX
        --sysconfdir=$PREFIX/etc
        --includedir=$PREFIX/include
        --bindir=$PREFIX/bin
        --sbindir=$PREFIX/sbin
        --libdir=$PREFIX/lib
        --libexecdir=$PREFIX/libexec
        --with-pear=$PREFIX/lib/php
        --with-gd
        --with-jpeg-dir=/opt/omni
        --with-png-dir=/opt/omni
        --with-freetype-dir=$FREETYPE_PATH
        --with-zlib
        --enable-pdo
        --with-mysql=/opt/omni
        --with-mysqli=/opt/omni/bin/$ISAPART64/mysql_config
        --with-pdo_sqlite
        --with-pdo-mysql=/opt/omni
        --with-pdo-pgsql=/opt/omni
        --with-pgsql=/opt/omni
        --with-bz2
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
        --with-openssl
        "

# We need to make a fake httpd.conf so apxs in make install
make_httpd_conf() {
    logmsg "Generating fake httpd.conf file"
    logcmd mkdir -p $DESTDIR/opt/apache22/conf
    echo -e "\n\n\nLoadModule access_module modules/mod_access.so\n\n\n" > \
        $DESTDIR/opt/apache22/conf/httpd.conf
}

# And a function to remove the temporary httpd.conf files
remove_httpd_conf() {
    logmsg "Removing Generated httpd.conf file"
    logcmd rm -rf $DESTDIR/opt/apache22/conf ||
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

# There are some dotfiles/dirs that look like noise
clean_dotfiles() {
    logmsg "--- Cleaning up dotfiles in destination directory"
    logcmd rm -rf $DESTDIR/.??* || \
        logerr "--- Unable to clean up destination directory"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
clean_dotfiles
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
