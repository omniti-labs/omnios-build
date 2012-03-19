#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=ipmitool
VER=1.8.11
VERHUMAN=$VER
PVER=0.1
PKG=system/management/ipmitool
SUMMARY="IPMI management tool"
DESC="$SUMMARY"

BUILDARCH=32
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --bindir=/usr/sbin --sbindir=/usr/lib"
CONFIGURE_OPTS="$CONFIGURE_OPTS --mandir=/usr/share/man
	--enable-intf-free=no
	--enable-solaris-opt"

install_smf(){
    logcmd mkdir -p $DESTDIR/lib/svc/manifest/network
    logcmd mkdir -p $DESTDIR/lib/svc/method
    logcmd cp $SRCDIR/files/ipmievd.xml $DESTDIR/lib/svc/manifest/network/ipmievd.xml
    logcmd cp $SRCDIR/files/svc-ipmievd $DESTDIR/lib/svc/method/svc-ipmievd
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
run_autoconf
build
install_smf
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
