#!/usr/bin/bash
# Load support functions
if [[ -n "$SUDO_USER" ]]; then
    echo "Unlike other scripts, this one can't be run under sudo."
    exit
fi
SKIP_ROOT_CHECK=1
. ../../lib/functions.sh

# This are used so people can see what packages get built.. pkg actually publishes
PKG=package/pkg
PKG=system/zones/brand/ipkg
SUMMARY="This isn't used, it's in the makefiles for pkg"
DESC="This isn't used, it's in the makefiles for pkg"

PROG=pkg
VER=omni
BUILDNUM=151002
if [[ -z "$PKGPUBLISHER" ]]; then
    logerr "No PKGPUBLISHER specified in config.sh"
    exit # Force it, we're fucked here.
fi

GIT=/usr/bin/git
GITHASH=
HEADERS="libbrand.h libuutil.h libzonecfg.h"
BRAND_CFLAGS="-I./gate-include"

BUILD_DEPENDS_IPS="developer/versioning/git developer/versioning/mercurial"
DEPENDS_IPS="runtime/python-26@2.6.7"

clone_gate(){
    logmsg "gate -> $TMPDIR/$BUILDDIR/illumos-omni-os"
    logcmd mkdir -p $TMPDIR/$BUILDDIR
    pushd $TMPDIR/$BUILDDIR > /dev/null 
    if [[ ! -d illumos-omni-os ]]; then
        logcmd  $GIT clone -b omni src@src.omniti.com:~omni-os/core/illumos-omni-os 
    fi
    logcmd  cd illumos-omni-os || logerr "gate inaccessible"
    popd > /dev/null 
}

crib_headers(){
    clone_gate
    mkdir -p $TMPDIR/$BUILDDIR/pkg/src/brand/gate-include ||
        logerr "Cannot create include stub directory"
    for hdr in $HEADERS; do
        for file in $(find $TMPDIR/$BUILDDIR/illumos-omni-os -name $hdr); do
            cp $file $TMPDIR/$BUILDDIR/pkg/src/brand/gate-include/ ||
                logerr "Copy failed"
        done
    done
}

clone_source(){
    logmsg "pkg -> $TMPDIR/$BUILDDIR/pkg"
    logcmd mkdir -p $TMPDIR/$BUILDDIR
    pushd $TMPDIR/$BUILDDIR > /dev/null 
    if [[ ! -d pkg ]]; then
        logcmd $GIT clone -b omni src@src.omniti.com:~omni-os/core/pkg
    fi
    pushd pkg > /dev/null || logerr "no source"
    if [ -n "${GITHASH}" ]; then
        logcmd $GIT checkout $GITHASH || logerr "failed update"
    fi
    popd > /dev/null
    popd > /dev/null 
}

build(){
    pushd $TMPDIR/$BUILDDIR/pkg/src > /dev/null || logerr "Cannot change to src dir"
    find . -depth -name \*.mo -exec touch {} \;
    touch `find gui/help -depth -name \*.in | sed -e 's/\.in$//'`
    pushd $TMPDIR/$BUILDDIR/pkg/src/brand > /dev/null
    logmsg "--- brand subbuild"
    ISALIST=i386 CC=gcc CFLAGS="$BRAND_CFLAGS" logcmd make \
        CODE_WS=$TMPDIR/$BUILDDIR/pkg || logerr "brand make failed"
    popd
    logmsg "--- toplevel build"
    ISALIST=i386 CC=gcc logcmd make \
        CODE_WS=$TMPDIR/$BUILDDIR/pkg || logerr "toplevel make failed"
    logmsg "--- proto install"
    ISALIST=i386 CC=gcc logcmd make install \
        CODE_WS=$TMPDIR/$BUILDDIR/pkg || logerr "proto install failed"
    popd > /dev/null
}
package(){
    pushd $TMPDIR/$BUILDDIR/pkg/src/pkg > /dev/null
    logmsg "--- packaging"
    ISALIST=i386 CC=gcc logcmd make \
        CODE_WS=$TMPDIR/$BUILDDIR/pkg \
        BUILDNUM=$BUILDNUM || logerr "pkg make failed"
    ISALIST=i386 CC=gcc logcmd make publish-pkgs \
        CODE_WS=$TMPDIR/$BUILDDIR/pkg \
        BUILDNUM=$BUILDNUM \
        PKGSEND_OPTS="" \
        PKGPUBLISHER=$PKGPUBLISHER \
        PKGREPOTGT="" \
        PKGREPOLOC="$PKGSRVR" \
        || logerr "publish failed"
    popd > /dev/null
}

init
clone_source
# This is hugely expensive
# We've committed these files to pkg, but they need to be kept up to date
#crib_headers
build
package
