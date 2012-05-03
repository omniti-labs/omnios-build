#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=httpd
VER=2.2.22
PKG=omniti/server/apache22
SUMMARY="$PROG - Apache Web Server ($VER)"
DESC="$SUMMARY"

DEPENDS_IPS="omniti/library/apr
             omniti/library/apr-util
             library/security/openssl
             database/sqlite-3"

PREFIX=/opt/apache22
reset_configure_opts

MIRROR=archive.apache.org
DIR=dist/httpd # Mirror directory to download from
MPMS="worker prefork event" # Which MPMs to build

LAYOUT=SolAmd32
LAYOUT64=SolAmd64

# General configure options - BASE is for options to be applied everywhere
# and the 32/64 variables are for 32/64 bit builds.
CONFIGURE_OPTS_BASE="--enable-dtrace
    --enable-ldap
    --enable-authnz-ldap
    --enable-ssl
    --with-ssl=/opt/omni
    --enable-file-cache
    --enable-proxy
    --enable-proxy-http
    --enable-cache
    --enable-disk-cache
    --enable-mem-cache
    --enable-modules=all
    --disable-reqtimeout
    --disable-proxy-scgi"
CONFIGURE_OPTS_32="
    --enable-layout=$LAYOUT
    --with-apr=/opt/omni/bin/$ISAPART/apr-1-config
    --with-apr-util=/opt/omni/bin/$ISAPART/apu-1-config"
CONFIGURE_OPTS_64="
    --enable-layout=$LAYOUT64
    --with-apr=/opt/omni/bin/$ISAPART64/apr-1-config
    --with-apr-util=/opt/omni/bin/$ISAPART64/apu-1-config"

CFLAGS32="-D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE"
CPPFLAGS32="-D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE"
LDFLAGS32="$LDFLAGS32 -L/opt/omni/lib -R/opt/omni/lib"
LDFLAGS64="$LDFLAGS64 -L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64"
CFLAGS64="$CFLAGS64 -g"

# Run a build for each MPM
# This function is provided with a callback parameter - this should be the
# name of the function to call to actually do the building
build_mpm() {
    CALLBACK=$1
    for MPM in $MPMS; do
        logmsg "Building $MPM MPM"
        if [[ "$MPM" != "prefork" ]]; then
            CONFIGURE_OPTS="$CONFIGURE_OPTS_BASE
                --with-program-name=httpd.$MPM
                --with-mpm=$MPM"
        else
            # prefork doesn't need any special options
            CONFIGURE_OPTS="$CONFIGURE_OPTS_BASE"
        fi
        # run the callback function
        $CALLBACK
    done
}

# Redefine the build32/build64 to build all MPMs
save_function build32 build32_orig
save_function build64 build64_orig

build32() {
    build_mpm build32_orig
}

build64() {
    perl -pi -e "
    s#-L/opt/omni/lib#-L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64#g;
    s#(-[LR]/opt/omni/lib(?!/))#"'$1'"/$ISAPART64#g;
    s#^EXTRA_LDFLAGS = .+#EXTRA_LDFLAGS = #;
    " $TMPDIR/$BUILDDIR/build/config_vars.mk
    build_mpm build64_orig
}

# Extra script/file installs
add_file() {
    cp $SRCDIR/files/$1 $DESTDIR$PREFIX/$2
    if [[ -n "$3" ]]; then
        chmod $3 $DESTDIR$PREFIX/$2
    else
        chmod 0444 $DESTDIR$PREFIX/$2
    fi
}

add_extra_files() {
    logmsg "Installing custom files and scripts"
    add_file manifest-http-apache.xml conf/http-apache.xml
    add_file method-http-apache bin/method-http-apache 0555
    rm -f $DESTDIR$PREFIX/conf/httpd.*.conf
    mv $DESTDIR$PREFIX/conf/httpd.conf $DESTDIR$PREFIX/conf/httpd.conf.dist
    add_file httpd.conf conf/httpd.conf
}

# Add some more files once the source code has been downloaded
save_function download_source download_source_orig
download_source() {
    download_source_orig "$@"
    cp $SRCDIR/files/config.layout $TMPDIR/$BUILDDIR/
}

# Add another step after patching the source (a new file needs to be made
# executable
save_function patch_source patch_source_orig
patch_source() {
    patch_source_orig
    chmod +x $TMPDIR/$BUILDDIR/libtool-dep-extract
}

init
download_source $DIR $PROG $VER
patch_source
prep_build
build
make_isa_stub
add_extra_files
make_package
clean_up
