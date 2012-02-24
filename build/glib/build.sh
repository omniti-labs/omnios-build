#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=glib       # App name
VER=2.30.2      # App version
PVER=1          # Package Version
PKG=library/glib2 # Package name (without prefix)
SUMMARY="$PROG - GNOME GLib utility library"
DESC="$SUMMARY"

DEPENDS_IPS="SUNWcs library/libffi library/zlib system/library libgcc_s runtime/perl-510"

CONFIGURE_OPTS="--disable-fam --disable-dtrace"

save_function configure32 configure32_orig
save_function configure64 configure64_orig
configure32() {
    LIBFFI_CFLAGS=-I/usr/lib/libffi-3.0.9/include
    export LIBFFI_CFLAGS
    LIBFFI_LIBS=-lffi
    export LIBFFI_LIBS
    configure32_orig
}
configure64() {
    LIBFFI_CFLAGS=-I/usr/lib/amd64/libffi-3.0.9/include
    export LIBFFI_CFLAGS
    LIBFFI_LIBS=-lffi
    export LIBFFI_LIBS
    configure64_orig
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
