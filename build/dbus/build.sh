#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=dbus       # App name
VER=1.4.16      # App version
PVER=1          # Package Version
PKG=dbus ##IGNORE##
SUMMARY="$PROG - IPC-based message notifications"
DESC="$SUMMARY"

DEPENDS_IPS="SUNWcs"

CPPFLAGS="$CPPFLAGS -D__EXTENSIONS__ -D_REENTRANT"
CONFIGURE_OPTS="--with-x=no --with-dbus-user=root --disable-static --with-dbus-daemondir=/usr/lib
	--bindir=/usr/bin --localstatedir=/var --libexecdir=/usr/libexec"

# We build backwards here on purpose so that 32bit binaries win (for install collisions).
build() {
    if [[ $BUILDARCH == "64" || $BUILDARCH == "both" ]]; then
        build64
    fi
    if [[ $BUILDARCH == "32" || $BUILDARCH == "both" ]]; then
        build32
    fi
}

post_install() {
    mkdir -p $DESTDIR/var/svc/manifest/system
    cp files/dbus.xml $DESTDIR/var/svc/manifest/system/dbus.xml
    chmod 444 $DESTDIR/var/svc/manifest/system/dbus.xml
    mkdir -p $DESTDIR/lib/svc/method
    cp files/svc-dbus $DESTDIR/lib/svc/method/svc-dbus
    chmod 555 $DESTDIR/lib/svc/method/svc-dbus
    mkdir -p $DESTDIR/etc/security/auth_attr.d
    mkdir -p $DESTDIR/etc/security/prof_attr.d
    cp files/auth-system%2Flibrary%2Fdbus $DESTDIR/etc/security/auth_attr.d/system%2Flibrary%2Fdbus
    cp files/prof-system%2Flibrary%2Fdbus $DESTDIR/etc/security/prof_attr.d/system%2Flibrary%2Fdbus
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
post_install
fix_permissions

PKG=system/library/dbus
SUMMARY="Simple IPC library based on messages"
DESC="Simple IPC library based on messages"
make_package dbus.mog

PKG=system/library/libdbus
SUMMARY="Simple IPC library based on messages - client libraries"
DESC="Simple IPC library based on messages - client libraries"
make_package libdbus.mog

#clean_up
