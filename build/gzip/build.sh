#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=gzip         # App name
VER=1.4           # App version
VERHUMAN=$VER     # Human-readable version
PVER=1            # Package Version (numeric only)
PKG=compress/gzip # Package name (without prefix)
SUMMARY="The GNU Zip (gzip) compression utility"
DESC="$SUMMARY $VER"

CONFIGURE_OPTS="--infodir=/usr/sfw/share/info"
BUILDARCH=32

# Solaris renames the z* utilities to gz* so we have to update the docs
rename_in_docs() {
    logmsg "Renaming z->gz references in documentation"
    pushd $TMPDIR/$BUILDDIR > /dev/null
    for file in `ls *.1 *.info z*.in` ; do
        logcmd mv $file $file.tmp
        logmsg "Running: sed -f $SRCDIR/renaming.sed $file.tmp > $file"
        sed -f $SRCDIR/renaming.sed $file.tmp > $file
        logcmd rm -f $file.tmp
    done
    popd > /dev/null
}

# Renames z* binaries and man pages to gz* in the DESTDIR
rename_files() {
    logmsg "Renaming z->gz files in $DESTDIR"
    for dir in $DESTDIR$PREFIX/bin/$ISAPART $DESTDIR$PREFIX/share/man/man1; do
        pushd $dir
        for zfile in `ls z*`; do
            logcmd mv $zfile g$zfile
        done
        popd > /dev/null
    done
}

build32() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 32-bit"
    export ISALIST="$ISAPART"
    make_clean
    configure32
    make_prog32
    rename_in_docs
    make_install32
    rename_files
    popd > /dev/null
    unset ISALIST
    export ISALIST
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
logerr "Intentional fail-- check contents"
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
