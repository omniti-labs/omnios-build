#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=zip         # App name
VER=3.0          # App version
VERHUMAN=$VER    # Human-readable version
PVER=1           # Package Version (numeric only)
PKG=compress/zip # Package name (without prefix)
SUMMARY="The Info-Zip (zip) compression utility"
DESC="$SUMMARY"

BUILDDIR=$PROG${VER//./}
BUILDARCH=32

configure32() {
    export ISAPART DESTDIR PREFIX
}

make_prog() {
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    logmsg "--- make"
    logcmd $MAKE $MAKE_JOBS -f unix/Makefile generic_gcc || \
        logerr "--- Make failed"
}

make_install() {
    logmsg "--- make install"
    logcmd $MAKE -f unix/Makefile install || \
        logerr "--- Make install failed"
}

init
download_source $PROG $PROG${VER//./}
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
