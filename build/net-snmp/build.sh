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

NO_PARALLEL_MAKE=true

DEPENDS_IPS="SUNWcs shell/bash system/library
             system/management/snmp/sea/sea-config"

MIB_MODULES="host disman/event-mib ucd-snmp/diskio udp-mib tcp-mib if-mib"

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

# Jam in some SMF files
place_smf_files() {
    logmsg "Installing SMF files"
    for dir in lib/svc/manifest/application/management lib/svc/method; do
        logcmd mkdir -p $DESTDIR$PREFIX/$dir || \
            logerr "--- Failed to create directory $DESTDIR$PREFIX/$dir"
    done
    logcmd cp $SRCDIR/files/net-snmp.xml $DESTDIR$PREFIX/lib/svc/manifest/application/management/
    logcmd cp $SRCDIR/files/svc-net-snmp $DESTDIR$PREFIX/lib/svc/method/
    logcmd chmod +x $DESTDIR$PREFIX/lib/svc/method/svc-net-snmp
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
place_smf_files
fix_permissions
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
