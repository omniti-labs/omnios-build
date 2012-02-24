#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=dbus-glib  # App name
VER=0.98        # App version
PVER=1          # Package Version
PKG=system/library/libdbus-glib # Package name (without prefix)
SUMMARY="$PROG - GNOME GLib DBUS integration library"
DESC="$SUMMARY"

DEPENDS_IPS="system/library/libdbus library/glib2 library/zlib system/library libgcc_s"

CONFIGURE_OPTS="--disable-fam --disable-dtrace --disable-tests"
GLIB_GENMARSHAL=/usr/bin/glib-genmarshal
export GLIB_GENMARSHAL

save_function configure32 configure32_orig
save_function configure64 configure64_orig
configure32() {
    DBUS_LIBS=-ldbus-1
    export DBUS_LIBS
    DBUS_CFLAGS="-I/usr/include/dbus-1.0 -I/usr/lib/dbus-1.0/include"
    export DBUS_CFLAGS
    DBUS_GLIB_CFLAGS="-I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include"
    export DBUS_GLIB_CFLAGS
    DBUS_GLIB_LIBS="-lglib-2.0 -lgobject-2.0 -lgio-2.0"
    export DBUS_GLIB_LIBS
    configure32_orig
    logcmd mv config.status config.status.old || logerr "status backup failed"
    sed -e 's/S\["GLIB_GENMARSHAL"\]=""/S["GLIB_GENMARSHAL"]="glib-genmarshal"/' < config.status.old > config.status || logerr "sed failed"
    logcmd chmod 755 config.status || logerr "chmod failed"
    logcmd ./config.status || logerr "config status"
}
configure64() {
    DBUS_LIBS=-ldbus-1
    export DBUS_LIBS
    DBUS_CFLAGS="-I/usr/include/amd64/dbus-1.0 -I/usr/lib/amd64/dbus-1.0/include"
    export DBUS_CFLAGS
    DBUS_GLIB_CFLAGS="-I/usr/include/amd64/glib-2.0 -I/usr/lib/amd64/glib-2.0/include"
    export DBUS_GLIB_CFLAGS
    DBUS_GLIB_LIBS="-lglib-2.0 -lgobject-2.0 -lgio-2.0"
    export DBUS_GLIB_LIBS
    configure64_orig
    logcmd mv config.status config.status.old || logerr "status backup failed"
    sed -e 's/S\["GLIB_GENMARSHAL"\]=""/S["GLIB_GENMARSHAL"]="glib-genmarshal"/' < config.status.old > config.status || logerr "sed failed"
    logcmd chmod 755 config.status || logerr "chmod failed"
    logcmd ./config.status || logerr "config status"
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
