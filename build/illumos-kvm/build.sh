#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

# First we build the kernel module
PROG=illumos-kvm
VER=1.0.2         # Keep this the same for the utilities build below
PVER=0.151002     # Make this match the desired omni-os branch
COMMIT=9621d5228ac4dbdd99cdfe8f2946e7315261a893
SRC_REPO=https://github.com/joyent/illumos-kvm.git
KERNEL_SOURCE=/code/omni-os-151002/illumos-omni-os
PROTO_AREA=$KERNEL_SOURCE/proto
PATCHDIR=patches.$PROG
PKG=driver/virtualization/kvm
SUMMARY="Illumos KVM kernel driver ($PROG ${COMMIT:0:10})"
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

# Next, the utilities
PROG=illumos-kvm-cmd
VER=1.0.2         # Keep this the same as the kernel driver above
PVER=0.151002     # Make this match the desired omni-os branch
COMMIT=099e212e968550ab97f7ba3431e55d9c16a0c78d
SRC_REPO=https://github.com/joyent/illumos-kvm-cmd.git
KERNEL_SOURCE=/code/omni-os-151002/illumos-omni-os
KVM_DIR=$TMPDIR/illumos-kvm-$VER
PATCHDIR=patches.$PROG
PKG=system/kvm
SUMMARY="Illumos KVM utilities ($PROG ${COMMIT:0:10})"
DESC="KVM is the kernel virtual machine, a framework for the in-kernel acceleration of QEMU."

# Reset a couple of important things
BUILDDIR=$TMPDIR/$PROG-$VER  # This must be explicitly reset from the run above
PREFIX=/usr

BUILD_DEPENDS_IPS="developer/gcc-3 developer/versioning/git file/gnu-coreutils"

# Only 64-bit matters
BUILDARCH=64

make_prog() {
    CC=/opt/gcc-4.6.2/bin/gcc
    export KERNEL_SOURCE KVM_DIR PREFIX CC
    logmsg "--- build.sh"
    logcmd ./build.sh || \
        logerr "--- build.sh failed"
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
