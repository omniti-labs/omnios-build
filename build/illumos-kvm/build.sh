#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=illumos-kvm
VER=1.0.2
PVER=0.151002 # Make this match the desired omni-os branch
COMMIT=9621d5228ac4dbdd99cdfe8f2946e7315261a893
SRC_REPO=https://github.com/joyent/illumos-kvm.git
KERNEL_SOURCE=/code/omni-os-151002/illumos-omni-os
PROTO_AREA=$KERNEL_SOURCE/proto
PKG=driver/virtualization/kvm
SUMMARY="KVM for Illumos (kernel driver)"
DESC="KVM is the kernel virtual machine, a framework for the in-kernel acceleration of QEMU."

BUILD_DEPENDS_IPS="developer/gcc-3 developer/versioning/git"

# Only 64-bit matters
BUILDARCH=64

# Unset the prefix because we actually DO want things in kernel etc
PREFIX="" 

download_source() {
    logmsg "Obtaining source files"
    if [[ -d $TMPDIR/$BUILDDIR ]]; then
        logmsg "--- Removing existing directory for a fresh start"
        logcmd rm -rf $TMPDIR/$BUILDDIR
    fi
    logcmd /bin/git clone $SRC_REPO $TMPDIR/$BUILDDIR
    logmsg "--- Setting revision to $COMMIT"
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd /bin/git checkout $COMMIT
    popd > /dev/null
}

configure64() {
    true
}

make_prog() {
    logmsg "--- make"
    logcmd $MAKE \
           KERNEL_SOURCE=$KERNEL_SOURCE \
           PROTO_AREA=$PROTO_AREA \
           GCC=/usr/sfw/bin/gcc || \
        logerr "--- Make failed"
}

init
download_source
patch_source
prep_build
build
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
