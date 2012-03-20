#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=net-snmp
VER=5.4.4
VERHUMAN=$VER
PVER=1
PKG=system/management/snmp/net-snmp
SUMMARY="Net-SNMP Agent files and libraries"
DESC="$SUMMARY ($VER)"

DEPENDS_IPS="SUNWcs shell/bash system/library
             system/management/snmp/sea/sea-config"

MIB_MODULES="host disman/event-mib ucd-snmp/diskio udp-mib tcp-mib if-mib"

CONFIGURE_OPTS="
    --with-defaults
    --with-default-snmp-version=3
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
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
