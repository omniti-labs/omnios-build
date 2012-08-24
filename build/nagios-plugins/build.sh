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

PROG=nagios-plugins
VER=1.4.13
VERHUMAN=$VER
PKG=omniti/monitoring/nagios/nagios-plugins
SUMMARY="Plugins for running checks under Nagios"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="omniti/database/mysql-55/library omniti/network/fping omniti/runtime/perl omniti/incorporation/perl-516-incorporation"
DEPENDS_IPS="omniti/database/mysql-55/library omniti/network/fping omniti/runtime/perl omniti/incorporation/perl-516-incorporation"

PREFIX=/opt/nagios
reset_configure_opts

# Trusted path for executables called by scripts
TRUSTED_PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/omni/bin:/opt/omni/sbin"

CFLAGS="-I/opt/omni/include"
LDFLAGS32="$LDFLAGS32 -L/opt/omni/lib -R/opt/omni/lib"
LDFLAGS64="$LDFLAGS64 -L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64"

CONFIGURE_OPTS="--with-nagios-user=$USER
    --with-nagios-group=users
    --with-fping-command=/opt/omni/sbin/fping
    --without-ipv6
    --without-apt-get-command
    --with-cgi-url=/cgi-bin
    --with-trusted-path=$TRUSTED_PATH
    --without-gnutls
    --with-perl=/opt/OMNIperl/bin/perl
    --with-mysql=/opt/omni"

# We need to set our own 32 bit configure opts to put the libexec stuff under
# $PREFIX/libexec/i386
CONFIGURE_OPTS_32="--prefix=$PREFIX
    --sysconfdir=$PREFIX/etc
    --bindir=$PREFIX/bin/$ISAPART
    --sbindir=$PREFIX/sbin/$ISAPART
    --libdir=$PREFIX/lib
    --libexecdir=$PREFIX/libexec/$ISAPART"

fix_utils_pm() {
    logmsg "Fixing utils.pm library"
    logcmd rm -f $DESTDIR/$PREFIX/libexec/utils.pm || \
        logerr "--- Failed to remove isaexec wrapper binary"
    logcmd cp $DESTDIR/$PREFIX/libexec/$ISAPART/utils.pm \
        $DESTDIR/$PREFIX/libexec || \
        logerr "--- Failed to move utils.pm file"

}

init
download_source nagios $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_utils_pm
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
