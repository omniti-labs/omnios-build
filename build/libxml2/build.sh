#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=libxml2        # App name
VER=2.7.8           # App version
PVER=4.1            # Package Version
PKG=library/libxml2 # Package name (without prefix)
SUMMARY="$PROG - XML C parser and toolkit"
DESC="$SUMMARY"

DEPENDS_IPS="system/library/gcc-4-runtime library/zlib@1.2.6"

fix_python_install() {
    logcmd mkdir -p $DESTDIR/usr/lib/python2.6/vendor-packages/64 || logerr "failed mkdir"
    logcmd mv $DESTDIR/usr/lib/python2.6/site-packages/* $DESTDIR/usr/lib/python2.6/vendor-packages/ || logerr "failed relocating python install"
    logcmd mv $DESTDIR/usr/lib/amd64/python2.6/site-packages/lib* $DESTDIR/usr/lib/python2.6/vendor-packages/64/ || logerr "failed relocating amd64 python install"
    logcmd rm -rf $DESTDIR/usr/lib/python2.6/site-packages || logerr "failed removing bad python install"
    logcmd rm -rf $DESTDIR/usr/lib/amd64/python2.6/site-packages || logerr "failed removing bad amd64 python install"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
fix_python_install
make_isa_stub
fix_permissions
make_package
clean_up
