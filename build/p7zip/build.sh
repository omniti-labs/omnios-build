#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=p7zip          # App name
VER=9.20.1          # App version
VERHUMAN=$VER       # Human-readable version
PVER=1              # Package Version (numeric only)
PKG=compress/p7zip  # Package name (without prefix)
SUMMARY="The p7zip compression and archiving utility"
DESC="$SUMMARY"

SRCVER="${VER}_src_all"
BUILDDIR=${PROG}_${VER}
BUILDARCH=32

DEPENDS_IPS="system/library/g++-4-runtime system/library/gcc-4-runtime"

configure32() {
    DEST_HOME=$DESTDIR$PREFIX
    DEST_BIN=$DEST_HOME/bin/$ISAPART
    DEST_SHARE=$DEST_HOME/lib
    DEST_SHARE_DOC=$DEST_HOME/share/doc/p7zip
    DEST_MAN=$DEST_HOME/share/man
    export DEST_HOME DEST_BIN DEST_SHARE DEST_SHARE_DOC DEST_MAN
}

make_prog() {
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    logmsg "--- make"
    logcmd $MAKE $MAKE_JOBS all3 || \
        logerr "--- Make failed"
}

build32() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 32-bit"
    export ISALIST="$ISAPART"
    make_clean
    configure32
    logcmd cp makefile.solaris_x86 makefile.machine
    make_prog32
    make_install32
    popd > /dev/null
    unset ISALIST
    export ISALIST
}

# Also include the shell wrapper for gzip-style compatibility
install_sh_wrapper() {
    pushd $TMPDIR/$BUILDDIR/contrib/gzip-like_CLI_wrapper_for_7z/ > /dev/null
    logmsg "Installing p7zip shell wrapper"
    logcmd cp p7zip $DEST_BIN/ || \
        logerr "--- Failed: unable to copy p7zip script"
    logcmd cp man1/p7zip.1 $DEST_MAN/man1/ || \
        logerr "--- Failed: unable to copy p7zip man page"
    popd > /dev/null
}

init
download_source $PROG ${PROG}_${SRCVER}
patch_source
prep_build
build
install_sh_wrapper
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
