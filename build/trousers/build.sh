#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=trousers   # App name
VER=0.3.8       # App version
VERHUMAN=$VER   # Human-readable version
PVER=2          # Package Version (numeric only)
PKG=library/security/trousers  # Package name (without prefix)
SUMMARY="trousers - TCG Software Stack - software for accessing a TPM device"
DESC="$SUMMARY ($VER)"

DEPENDS_IPS="system/library/gcc-4-runtime library/security/openssl@1.0.0"

LIBS="-lbsm -lnsl -lsocket -lgen -lscf -lresolv"

preprep_build() {
  pushd $TMPDIR/$BUILDDIR > /dev/null || logerr "Cannot change to build directory"
  for f in `ls src/include/tss/*.h` ; do
    /usr/bin/dos2unix $f $f
  done
  for f in `ls src/include/trousers/*.h` ; do
    /usr/bin/dos2unix $f $f
  done
  for f in `ls src/include/*.h` ; do
    /usr/bin/dos2unix $f $f
  done
  /opt/omni/bin/libtoolize -f || logerr "libtoolize failed"
  aclocal || logerr "aclocal failed"
  automake src/tspi/Makefile || logerr "automake failed"
  autoreconf -vi 2>&1 > /dev/null
  autoreconf -vi || logerr "autoreconf failed"
  popd > /dev/null
}

cleanup_configure() {
    for makefile in src/trspi/Makefile src/tspi/Makefile; do
        mv $makefile $makefile.unneeded
        cat $makefile.unneeded | sed -e 's/LIBS = .*/LIBS = -lnsl -lsocket -lgen/;' > $makefile
    done
}

configure32() {
    logmsg "--- configure (32-bit)"
    CFLAGS="$CFLAGS $CFLAGS32" \
    CXXFLAGS="$CXXFLAGS $CXXFLAGS32" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS32" \
    LDFLAGS="$LDFLAGS $LDFLAGS32" \
    CC=$CC CXX=$CXX \
    LIBS="$LIBS" \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_32 \
    $CONFIGURE_OPTS || \
        logerr "--- Configure failed"
    cleanup_configure
}

configure64() {
    logmsg "--- configure (64-bit)"
    CFLAGS="$CFLAGS $CFLAGS64" \
    CXXFLAGS="$CXXFLAGS $CXXFLAGS64" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS64" \
    LDFLAGS="$LDFLAGS $LDFLAGS64" \
    CC=$CC CXX=$CXX \
    LIBS="$LIBS" \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_64 \
    $CONFIGURE_OPTS || \
        logerr "--- Configure failed"
    cleanup_configure
}

init
download_source $PROG $PROG $VER
patch_source
preprep_build
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up
