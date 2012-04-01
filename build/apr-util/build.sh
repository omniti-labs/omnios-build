#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=apr-util
VER=1.4.1
PKG=omniti/library/apr-util
SUMMARY="$PROG - Apache Portable Runtime Utility"
DESC="$SUMMARY"

DEPENDS_IPS="omniti/library/apr@1.4 library/expat database/sqlite-3"
BUILD_DEPENDS_IPS="autoconf"

PLATFORM=`uname -p`
if [[ $PLATFORM == 'i386' ]]; then
    LAYOUT32=omni32
    LAYOUT64=omni64
else
    LAYOUT32=omnisparc32
    LAYOUT64=omnisparc64
fi

CPPFLAGS="$CPPFLAGS -I/opt/omni/include"
CPPFLAGS64="$CPPFLAGS64 -I/opt/omni/include/$ISAPART"
CFLAGS="$CFLAGS -I/opt/omni/include"
LDFLAGS32="$LDFLAGS32 -L/opt/omni/lib -R/opt/omni/lib"
LDFLAGS64="$LDFLAGS64 -L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64"


CONFIGURE_OPTS="--with-apr=/opt/omni
    --with-dbm=sdbm
    --with-ldap
    --without-pgsql
"
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32
    --enable-layout=$LAYOUT32 \
    --with-installbuilddir=/opt/omni/share/$ISAPART/build-1"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64
    --enable-layout=$LAYOUT64 \
    --with-installbuilddir=/opt/omni/share/$ISAPART64/build-1"

remove_existing_package() {
    ## We have to remove the package from the build system to ensure that the new 
    ## build is complete.
    PKGINFO="pkg info"
    PKGRM="pkg uninstall"
    if $PKGINFO $PKG >/dev/null 2>&1 ; then
        logmsg "Installed $PKG must be removed.  Running pkgrm."
        yes | $PKGRM $PKG
    else
        logmsg "No $PKG installed.  Good."
    fi
}

copy_config_layout() {
    logmsg "Copying config layout"
    cp $SRCDIR/files/config.layout $TMPDIR/$BUILDDIR/config.layout || \
        logerr "--- Failed to copy config.layout"
}

save_function configure32 orig_configure32
configure32() {
    logmsg "--- autoconf"
    autoconf || \
        logerr "------ Failed running autoconf"
    orig_configure32
}
save_function configure64 orig_configure64
configure64() {
    logmsg "--- autoconf"
    autoconf || \
        logerr "------ Failed running autoconf"
    orig_configure64
}

save_function build64 orig_build64
build64() {
    # Re-do the source dir as make distclean still leaves some 32 bit binaries
    # around
    logmsg "Removing source directory"
    rm -rf $TMPDIR/$BUILDDIR || \
        logerr "Failed to remove source directory"
    logmsg "Re-extracting source directory"
    download_source subversion $PROG $VER
    patch_source
    #prep_build
    copy_config_layout

    orig_build64
}

init
remove_existing_package
download_source $PROG $PROG $VER
patch_source
prep_build
copy_config_layout
build
make_isa_stub
make_package
clean_up
