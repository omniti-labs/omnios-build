#!/usr/bin/bash
# Load support functions
if [[ -n "$SUDO_USER" ]]; then
    echo "Unlike other scripts, this one can't be run under sudo."
    exit
fi
SKIP_ROOT_CHECK=1
. ../../lib/functions.sh

PROG=pkg
VER=a9ba687c5423
BUILDNUM=151002

GIT=/opt/omni/bin/git
HG=/opt/omni/bin/hg
HEADERS="libbrand.h libuutil.h libzonecfg.h"
BRAND_CFLAGS="-I./gate-include"

clone_gate(){
    logmsg "gate -> $TMPDIR/$BUILDDIR/illumos-omni-os"
    logcmd mkdir -p $TMPDIR/$BUILDDIR
    pushd $TMPDIR/$BUILDDIR > /dev/null 
    if [[ ! -d illumos-omni-os ]]; then
        logcmd  $GIT clone -b omni src@src.omniti.com:~omni-os/core/illumos-omni-os 
    fi
    logcmd  cd illumos-omni-os 
    popd > /dev/null 
}

crib_headers(){
    mkdir -p $TMPDIR/$BUILDDIR/pkg-omni/src/brand/gate-include ||
        logerr "Cannot create include stub directory"
    for hdr in $HEADERS; do
        for file in $(find $TMPDIR/$BUILDDIR/illumos-omni-os -name $hdr); do
            echo "--- $file"
            cp $file $TMPDIR/$BUILDDIR/pkg-omni/src/brand/gate-include/ ||
                logerr "Copy failed"
        done
    done
}

clone_source(){
    logmsg "pkg -> $TMPDIR/$BUILDDIR/pkg-omni"
    logcmd mkdir -p $TMPDIR/$BUILDDIR
    pushd $TMPDIR/$BUILDDIR > /dev/null 
    if [[ ! -d pkg-omni ]]; then
        logcmd $HG clone -b omni ssh://src@src.omniti.com/~omni-os/core/pkg-omni
    fi
    logcmd hg update $VER
    popd > /dev/null 
}

build(){
    pushd $TMPDIR/$BUILDDIR/pkg-omni/src > /dev/null
    pushd $TMPDIR/$BUILDDIR/pkg-omni/src/brand > /dev/null
    logmsg "--- brand subbuild"
    ISALIST=i386 CC=gcc CFLAGS="$BRAND_CFLAGS" logcmd make || logerr "brand make failed"
    popd
    logmsg "--- toplevel build"
    ISALIST=i386 CC=gcc logcmd make || logerr "toplevel make failed"
    logmsg "--- proto install"
    ISALIST=i386 CC=gcc logcmd make install || logerr "proto install failed"
    popd > /dev/null
}
package(){
    pushd $TMPDIR/$BUILDDIR/pkg-omni/src/pkg > /dev/null
    logmsg "--- packaging"
    ISALIST=i386 CC=gcc logcmd make BUILDNUM=$BUILDNUM || logerr "pkg make failed"
    ISALIST=i386 CC=gcc logcmd make BUILDNUM=$BUILDNUM publish || logerr "publish failed"
    popd > /dev/null
}

init
clone_gate
clone_source
crib_headers
build
package
