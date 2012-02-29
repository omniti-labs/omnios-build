#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=cpp        # App name
VER=0.5.11
PVER=0.2012.2.29
PKG=developer/macro/cpp
SUMMARY="The C Pre-Processor (cpp)"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="gcc46 developer/parser/bison"
DEPENDS_IPS="SUNWcs"

CONFIGURE_OPTS=""

setup_src() {
   BUILDDIR=cpp-src
   logcmd mkdir -p $TMPDIR/$BUILDDIR
   logcmd cp $SRCDIR/files/* $TMPDIR/$BUILDDIR
}
build() {
    # Set the version to something reasonable
    pushd $TMPDIR/$BUILDDIR > /dev/null || logerr "can't enter build harness"
    logcmd gmake CC=gcc
    popd > /dev/null
}
make_install() {
    logcmd mkdir -p $DESTDIR/usr/lib || logerr "mkdir failed"
    logcmd mkdir -p $DESTDIR/usr/ccs/lib || logerr "mkdir failed"
    pushd $TMPDIR/$BUILDDIR > /dev/null || logerr "can't enter build harness"
    logcmd gmake install CC=gcc DESTDIR=$DESTDIR
    popd > /dev/null
    logcmd ln -s ../../lib/cpp $DESTDIR/usr/ccs/lib/cpp || logerr "softlink failed"
    logcmd cp $SRCDIR/schilix.license $DESTDIR/ || logerr "could not place license"
    logcmd cp $SRCDIR/caldera.license $DESTDIR/ || logerr "could not place license"
}

init
setup_src
prep_build
build
make_install
make_package
clean_up
