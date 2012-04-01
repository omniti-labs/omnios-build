#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=e2fsprogs
VER=1.41.14
PKG=omniti/library/uuid
SUMMARY="libuuid ($PROG)"
DESC="$SUMMARY"

make_prog() {
    logcmd pushd lib/uuid > /dev/null || logerr "pushd failed"
    logcmd gmake
    logcmd popd
}
make_install() {
    logcmd pushd lib/uuid > /dev/null || logerr "pushd failed"
    logcmd gmake DESTDIR=${DESTDIR} install
    logcmd gmake DESTDIR=${DESTDIR} install-shilbs
    logcmd popd
}

CONFIGURE_OPTS="--enable-elf-shlibs"

save_function configure32 configure32_orig
save_function configure64 configure64_orig

configure32() {
  configure32_orig
  perl -pi -e 's#-Wl,-rpath-link,\$\(top_builddir\)/lib##; s#--shared#-shared#;' $TMPDIR/$BUILDDIR/lib/uuid/Makefile
}

configure64() {
  configure64_orig
  perl -pi -e 's#-Wl,-rpath-link,\$\(top_builddir\)/lib##; s#--shared#-shared#;' $TMPDIR/$BUILDDIR/lib/uuid/Makefile
}

init
download_source $PROG $PROG $VER
patch_source
prep_build

build
make_isa_stub
make_package
clean_up
