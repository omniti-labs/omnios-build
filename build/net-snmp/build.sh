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

PROG=net-snmp
VER=5.7.2
VERHUMAN=$VER
PKG=system/management/snmp/net-snmp
SUMMARY="Net-SNMP Agent files and libraries"
DESC="$SUMMARY ($VER)"

NO_PARALLEL_MAKE=true

DEPENDS_IPS="SUNWcs shell/bash system/library
             system/management/snmp/sea/sea-config"

MIB_MODULES="host disman/event-mib ucd-snmp/diskio udp-mib tcp-mib if-mib"

LDFLAGS32="-Wl,-zignore $LDFLAGS32 -L/lib"
LDFLAGS64="-Wl,-zignore $LDFLAGS64 -L/lib/$ISAPART64"

# We want dual-arch libs but only care about 32-bit binaries
# We will elide 64-bit binaries with pkgmogrify (local.mog)
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --bindir=$PREFIX/bin --sbindir=$PREFIX/sbin"
CONFIGURE_OPTS="
    --with-defaults
    --with-default-snmp-version=3
    --includedir=$PREFIX/include
    --mandir=$PREFIX/share/man
    --with-logfile=/var/log/snmpd.log
    --with-persistent-directory=/var/net-snmp
    --with-mibdirs=/etc/net-snmp/snmp/mibs
    --datadir=/etc/net-snmp
    --enable-agentx-dom-sock-only
    --enable-ucd-snmp-compatibility
    --enable-ipv6
    --enable-mfd-rewrites
    --with-pkcs
    --disable-embedded-perl
    --without-perl-modules
    --disable-static
"

# Options with embedded spaces don't play well w/our functions
configure32() {
    logmsg "--- configure (32-bit)"
    CFLAGS="$CFLAGS $CFLAGS32" \
    CXXFLAGS="$CXXFLAGS $CXXFLAGS32" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS32" \
    LDFLAGS="$LDFLAGS $LDFLAGS32" \
    CC=$CC CXX=$CXX \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_32 \
    $CONFIGURE_OPTS --with-sys-contact="root@localhost" \
                    --with-transports="UDP TCP UDPIPv6 TCPIPv6" \
                    --with-mib-modules="$MIB_MODULES" || \
        logerr "--- Configure failed"
    perl -pi -e 's#^^(archive_cmds=.*)"$#$1 -nostdlib"#g;' libtool
}

configure64() {
    logmsg "--- configure (64-bit)"
    CFLAGS="$CFLAGS $CFLAGS64" \
    CXXFLAGS="$CXXFLAGS $CXXFLAGS64" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS64" \
    LDFLAGS="$LDFLAGS $LDFLAGS64" \
    CC=$CC CXX=$CXX \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_64 \
    $CONFIGURE_OPTS --with-sys-contact="root@localhost" \
                    --with-transports="UDP TCP UDPIPv6 TCPIPv6" \
                    --with-mib-modules="$MIB_MODULES" || \
        logerr "--- Configure failed"
    perl -pi -e 's#^^(archive_cmds=.*)"$#$1 -nostdlib"#g;' libtool
}

# Jam in some SMF files
place_smf_files() {
    logmsg "Installing SMF files"
    for dir in lib/svc/manifest/application/management lib/svc/method; do
        logcmd mkdir -p $DESTDIR/$dir || \
            logerr "--- Failed to create directory $DESTDIR/$dir"
    done
    logcmd cp $SRCDIR/files/net-snmp.xml $DESTDIR/lib/svc/manifest/application/management/
    logcmd cp $SRCDIR/files/svc-net-snmp $DESTDIR/lib/svc/method/
    logcmd chmod +x $DESTDIR/lib/svc/method/svc-net-snmp
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
place_smf_files
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
