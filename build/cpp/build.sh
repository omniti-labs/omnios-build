#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=schily        # App name
VER=2012-01-23     # App version
PVER=1             # Package Version
PKG=developer/macro/cpp
SUMMARY="The C Pre-Processor (cpp)"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="gcc46 developer/parser/bison"
DEPENDS_IPS="SUNWcs"

CONFIGURE_OPTS=""

build() {
    # Set the version to something reasonable
    VER=0.5.11
    logmsg "--- cleaning residue from any previous build"
    rm -rf $TMPDIR/$BUILDDIR/scratch
    logmsg "--- Executing unified make process"
    pushd $TMPDIR/$BUILDDIR/cpp > /dev/null || logerr "can't enter build harness"
    logcmd /bin/yacc cpy.y || logerr "Yacc failed"
    logcmd gcc -DUSE_STATIC_CONF -I../include -o cpp  cpp.c  y.tab.c || logerr "compilation failed"
    popd > /dev/null
}
make_install() {
    logcmd mkdir -p $DESTDIR/usr/lib || logerr "mkdir failed"
    logcmd mkdir -p $DESTDIR/usr/ccs/lib || logerr "mkdir failed"
    logcmd cp $TMPDIR/$BUILDDIR/cpp/cpp $DESTDIR/usr/lib/cpp || logerr "cp failed"
    logcmd chmod 755 $DESTDIR/usr/lib/cpp || logerr "chmod failed"
    logcmd ln -s ../../lib/cpp $DESTDIR/usr/ccs/lib/cpp || logerr "softlink failed"
    logcmd cp $SRCDIR/schilix.license $DESTDIR/ || logerr "could not place license"
    logcmd cp $SRCDIR/caldera.license $DESTDIR/ || logerr "could not place license"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_install
make_package
clean_up
