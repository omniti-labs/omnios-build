#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=ntp             # App name
VER=dev-4.2.7p259    # App version
VERHUMAN=4.2.7.259   # Human-readable version
PVER=0.1             # Package Version (numeric only)
PKG=service/network/ntp      # Package name (without prefix)
SUMMARY="Network Time Services"
DESC="$SUMMARY"

BUILDARCH=32

DEPENDS_IPS="SUNWcs library/security/openssl service/network/dns/mdns system/library/math system/library runtime/perl-5142"

CFLAGS="$CFLAGS -std=c99 -D_XOPEN_SOURCE=600 -D__EXTENSIONS__"
CONFIGURE_OPTS_32="--prefix=/usr
    --bindir=/usr/sbin
    --with-binsubdir=sbin
    --libexecdir=/usr/lib/inet
    --sysconfdir=/etc/inet
    --enable-all-clocks
    --enable-debugging
    --enable-debug-timing
    --disable-optional-args
    --enable-parse-clocks
    --enable-ignore-dns-errors
    --without-ntpsnmpd
    --without-sntp
    --without-lineeditlibs
    --with-openssl-libdir=/lib
    --disable-getifaddrs
"

overlay_root() {
    logcmd rm -f $DESTDIR/usr/sbin/tickadj
    logcmd ln -s ntpdc $DESTDIR/usr/sbin/xntpdc
    (cd $SRCDIR/root && tar cf - .) | (cd $DESTDIR && tar xf -)
    logcmd mkdir -p $DESTDIR/var/ntp/ntpstats
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
overlay_root
make_isa_stub
fix_permissions
VER=4.2.7.259
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
