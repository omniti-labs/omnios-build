#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=xz
VER=5.0.5
VERHUMAN=$VER
PKG=compress/xz
SUMMARY="XZ Utils - general-purpose data compression software"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="autoconf"

save_function configure32 configure32_orig
save_function configure64 configure64_orig

configure32() {
    configure32_orig
    pushd $TMPDIR/$BUILDDIR > /dev/null
    pushd src/liblzma > /dev/null
    logcmd gmake foo 2>&1 /dev/null
    popd > /dev/null
    logcmd perl -pi -e 's#^^(archive_cmds=.*)"$#$1 -nostdlib -lc"#g;' libtool || \
        logerr "patching libtool failed"
    popd > /dev/null
}

configure64() {
    configure64_orig
    pushd $TMPDIR/$BUILDDIR > /dev/null
    pushd src/liblzma > /dev/null
    logcmd gmake foo 2>&1 /dev/null
    popd > /dev/null
    logcmd perl -pi -e 's#^^(archive_cmds=.*)"$#$1 -nostdlib -lc"#g;' libtool || \
        logerr "patching libtool failed"
    popd > /dev/null
}
    
init
download_source $PROG $PROG $VER
patch_source
run_autoconf
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
