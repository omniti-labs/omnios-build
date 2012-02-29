#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=less       # App name
VER=443         # App version
PVER=0.1           # Package Version
PKG=text/less    # Package name (without prefix)
SUMMARY="$PROG - GNU paginator"
DESC="$SUMMARY"

DEPENDS_IPS="SUNWcs"

BUILDARCH=32
CONFIGURE_OPTS_32="--prefix=$PREFIX
        --sysconfdir=/etc
        --includedir=$PREFIX/include
        --bindir=$PREFIX/bin
        --sbindir=$PREFIX/sbin
        --libdir=$PREFIX/lib
        --libexecdir=$PREFIX/libexec"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
strip_install
fix_permissions
make_package
clean_up
