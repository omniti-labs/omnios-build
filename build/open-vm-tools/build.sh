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
# Copyright (c) 2014 by Delphix. All rights reserved.
#

# Load support functions
. ../../lib/functions.sh

PROG=open-vm-tools
BUILDDIR=open-vm-tools-9.4.0-1280544
VER=9.4.0
VERHUMAN=9.4.0
PKG=system/virtualization/open-vm-tools
SUMMARY="Open Virtual Machine Tools"
DESC="The Open Virtual Machine Tools project aims to provide a suite of open source virtualization utilities and drivers to improve the functionality and user experience of virtualization. The project currently runs in guest operating systems under the VMware hypervisor."

BUILD_DEPENDS_IPS='developer/pkg-config'
RUN_DEPENDS_IPS='library/glib2 system/library/gcc-4-runtime'

install_smf() {
	logmsg "Installing SMF components"
	logcmd mkdir -p $DESTDIR/lib/svc/manifest/system/virtualization || \
		logerr "--- Failed to create manifest directory"
	logcmd cp $SRCDIR/open-vm-tools.xml $DESTDIR/lib/svc/manifest/system/virtualization/ || \
		logerr "--- Failed to copy manifest file"
}

CFLAGS="-Wno-deprecated-declarations -Wno-unused-local-typedefs"
CONFIGURE_OPTS="
	--without-kernel-modules
	--disable-static
	--without-x
	--without-dnet
	--without-icu
	--without-gtk2
	--without-gtkmm
"
BUILDARCH=32

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
install_smf
make_isa_stub
make_package
clean_up
