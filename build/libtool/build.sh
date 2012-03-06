#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=libtool      # App name
VER=2.4           # App version
PVER=1            # Package Version
PKG=developer/build/libtool  ##IGNORE##
SUMMARY="libtool - GNU libtool utility"
DESC="GNU libtool - library support utility ($VER)"

DEPENDS_IPS="system/library system/library/gcc-4-runtime"

# The "binaries" here are just shell scripts so arch doesn't matter
# The includes also are not arch-dependent
CONFIGURE_OPTS="--bindir=$PREFIX/bin --includedir=$PREFIX/include --disable-static"
reset_configure_opts

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions

PKG=developer/build/libtool
VER=2.4
PVER=1
SUMMARY="libtool - GNU libtool utility"
DESC="GNU libtool - library support utility ($VER)"
make_package libtool.mog

PKG=library/libtool/libltdl
VER=2.4
PVER=1
SUMMARY="libltdl - GNU libtool dlopen wrapper"
DESC="GNU libtool dlopen wrapper - libltdl ($VER)"
make_package libltdl.mog

clean_up
