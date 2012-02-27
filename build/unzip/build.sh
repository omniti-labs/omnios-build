#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=unzip         # App name
VER=6.0            # App version
VERHUMAN=$VER      # Human-readable version
PVER=1             # Package Version (numeric only)
PKG=compress/unzip # Package name (without prefix)
SUMMARY="The Info-Zip (unzip) compression utility"
DESC="$SUMMARY"

BUILDDIR=$PROG${VER//./}
BUILDARCH=32

# Copied from upstream's pkg makefile
export LOCAL_UNZIP="-DUNICODE_SUPPORT -DNO_WORKING_ISPRINT -DUNICODE_WCHAR"

configure32() {
    export ISAPART
}

make_prog() {
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    logmsg "--- make"
    logcmd $MAKE $MAKE_JOBS -f unix/Makefile generic_gcc || \
        logerr "--- Make failed"
}

make_install() {
    logmsg "--- make install"
    logcmd $MAKE -f unix/Makefile prefix=$DESTDIR$PREFIX install || \
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
