#!/usr/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

# First we build the kernel module
PROG=illumos-kvm
VER=1.0.3
# Default to building tip, but if needed, specify the desired commit here
COMMIT=
SRC_REPO=https://github.com/joyent/illumos-kvm.git
KERNEL_SOURCE=/code/omnios-151004/illumos-omnios
PROTO_AREA=$KERNEL_SOURCE/proto/root_i386
PATCHDIR=patches.$PROG
PKG=driver/virtualization/kvm
SUMMARY="placeholder; reset below"
DESC="$SUMMARY"

# These are the dependencies for both the module and the cmds
BUILD_DEPENDS_IPS="archiver/gnu-tar developer/gcc46 developer/versioning/git file/gnu-coreutils"

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
    logcmd /bin/git clone $SRC_REPO $TMPDIR/$BUILDDIR || \
        logerr "--- Failed to clone from $SRC_REPO"
    if [[ -n "$COMMIT" ]]; then
        logmsg "--- Setting revision to $COMMIT"
        pushd $TMPDIR/$BUILDDIR > /dev/null
        logcmd /bin/git checkout $COMMIT
        popd > /dev/null
    fi
    if [[ -z "$COMMIT" ]]; then
        pushd $TMPDIR/$BUILDDIR > /dev/null
        COMMIT=$(git log -1 --format=format:%H)
        popd > /dev/null
    fi
}

configure64() {
    true
}

make_prog() {
    logmsg "--- make"
    logcmd $MAKE \
           KERNEL_SOURCE=$KERNEL_SOURCE \
           PROTO_AREA=$PROTO_AREA \
           CC=/opt/gcc-4.4.4/bin/gcc || \
        logerr "--- Make failed"
    logcmd cp $KERNEL_SOURCE/usr/src/OPENSOLARIS.LICENSE $SRCDIR/OPENSOLARIS.LICENSE || \
        logerr "--- failed to copy CDDL from kernel sources"
}
fix_drivers() {
    logcmd mv $DESTDIR/usr/kernel $DESTDIR/ || \
        logerr "--- couldn't move kernel bits into /"
}

init
download_source
patch_source
prep_build
build
fix_drivers
SUMMARY="Illumos KVM kernel driver ($PROG ${COMMIT:0:10})"
DESC="KVM is the kernel virtual machine, a framework for the in-kernel acceleration of QEMU."
make_package kvm.mog
clean_up

# Next, the utilities (they follow the kernel module version)
PROG=illumos-kvm-cmd
# Default to building tip, but if needed, specify the desired commit here
COMMIT=
SRC_REPO=https://github.com/joyent/illumos-kvm-cmd.git
KERNEL_SOURCE=/code/omnios-151004/illumos-omnios
KVM_DIR=$TMPDIR/illumos-kvm-$VER
PATCHDIR=patches.$PROG
PKG=system/kvm

# Reset a couple of important things
BUILDDIR=$PROG-$VER  # This must be explicitly reset from the run above
PREFIX=/usr

# Only 64-bit matters
BUILDARCH=64

# Borrowed from Joyent's build.sh within the source
# so we can find ctfconvert during 'make install'
CTFBINDIR="$KERNEL_SOURCE"/usr/src/tools/proto/root_i386-nd/opt/onbld/bin/i386
export CTFBINDIR
export PATH="$PATH:$CTFBINDIR"

make_prog() {
    CC=/opt/gcc-4.6.3/bin/gcc
    export KERNEL_SOURCE KVM_DIR PREFIX CC
    logmsg "--- build.sh"
    logcmd ./build.sh || \
        logerr "--- build.sh failed"
}

make_install() {
    logmsg "--- make install"
    logcmd $MAKE DESTDIR=${DESTDIR} V=1 install || \
        logerr "--- Make install failed"
}

download_source
patch_source
prep_build
build
SUMMARY="Illumos KVM utilities ($PROG ${COMMIT:0:10})"
DESC="KVM is the kernel virtual machine, a framework for the in-kernel acceleration of QEMU."
make_package kvm-cmd.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
