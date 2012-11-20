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

# Had to override some functions, put them here
. monkeypatch.sh

#PKGPUBLISHER=ms.omniti.com
#PKGSRVR=http://pkg-il-1.int.omniti.net:10007/

PKGPUBLISHER=root.omnios.omniti.com
PKGSRVR=http://localhost:888/

# General approach here is to download the SVR4 package from Oracle, then unpack 
# it and copy out what we want.

# This build script builds two packages: the global-only kernel driver package, and the NGZ user binaries.

#--------------------------------------------------------------------------#
#                      Part 1: Download and Unpack
#--------------------------------------------------------------------------#

# Ugggh, Oracle uses several different version numbers, in several different orders.
VBOX_VERSION=4.2.4
ORACLE_RELEASE=81684
ORACLE_PLATFORM=SunOS
VERHUMAN=$VBOX_VERSION
SUMMARY="DUMMY"
DESC="DUMMY"

# This was found in the SVR4 package's checkinstall script
DEPENDS_IPS="runtime/python-26 system/library/iconv/utf-8"

PROG=VirtualBox      # App name
VER=$VBOX_VERSION            # App version
#PVER=               # Branch (set in config.sh, override here if needed)
#PKG=drivers/virtualization/virtualbox   # Package name (e.g. library/foo)

init

# http://download.virtualbox.org/virtualbox/4.2.4/VirtualBox-4.2.4-81684-SunOS.tar.gz
MIRROR=download.virtualbox.org
URL_DIRECTORY=virtualbox/$VERHUMAN
DOWNLOAD_VERSION=$VBOX_VERSION-$ORACLE_RELEASE-$ORACLE_PLATFORM
SVR4_PACKAGE_FILE=VirtualBox-$VBOX_VERSION-$ORACLE_PLATFORM-r$ORACLE_RELEASE.pkg
download_source $URL_DIRECTORY $PROG $DOWNLOAD_VERSION

# OK, now we have a SVR4 pkg file.  Tempting to install it using pkgadd, 
# but the SVR4 package has scripts to install kernel modules (!) so let's not do that.
# Instead, use pkgtrans to unpack it.

UNPACKED_SVR4=$TMPDIR/$BUILDDIR/unpacked
mkdir -p $UNPACKED_SVR4
if [[ ! -e $UNPACKED_SVR4/SUNWvbox/root/opt/VirtualBox/VBoxBalloonCtrl ]]; then
    logmsg "Unpacking SVR4 package into $UNPACKED_SVR4"
    logcmd pkgtrans $TMPDIR/$BUILDDIR/$SVR4_PACKAGE_FILE $UNPACKED_SVR4 all ||
      logerr "-- Unable to unpack SVR4 package"
else
    logmsg "SVR4 package appears to already be unpacked"
fi


#--------------------------------------------------------------------------#
#                    Part 2: Kernel Module Package
#--------------------------------------------------------------------------#

#PVER=               # Branch (set in config.sh, override here if needed)
PKG=drivers/virtualization/virtualbox   # Package name (e.g. library/foo)
SUMMARY="Kernel modules (drivers) for VirtualBox $VERHUMAN."      # One-liner, must be filled in
DESC="IPS repackaging of SunOS binaries released by Oracle.  Gotchas about this IPS package:  * Must be installed on a global zone.  * Crossbow networking for VBox is disabled; we get errors when trying to load the module.  * Runs 2 SMF services in the global zone: one custom transient to install drivers, and the zoneaccess service provided by Oracle  * Requires execution of the following command on each NGZ that is to use VirtualBox: zonecfg -z <yourzone> 'add device; set match=/dev/vboxdrv; end'"

# This just sets up the dummy install path in $DESTDIR
prep_build

# Start copying files to the installation dir.
logmsg "$PKG - Copying files from unpacked SVR4 package to installation image"

# Copy the kernel drivers, but not the USB drivers
logcmd cp -r $UNPACKED_SVR4/SUNWvbox/root/platform $DESTDIR
logcmd rm -f $DESTDIR/platform/i86pc/kernel/drv/vboxusb{,mon}{,.conf}

logcmd mkdir -p $DESTDIR/var/svc/manifest/application/virtualbox/

# Add in a transient service definition of our own, to run the driver installation.
logcmd cp $SRCDIR/virtualbox-kerneldriver.xml $DESTDIR/var/svc/manifest/application/virtualbox/

# This service must run in the global zone.  
# We've modified it to auto-start, and be dependednt on the driver install.
logcmd cp $SRCDIR/virtualbox-zoneaccess.xml $DESTDIR/var/svc/manifest/application/virtualbox/

# Now then copy in the VBoxZoneAccess binary and its .so
# Be careful here, since we can't overlap with the client binaries install!
logcmd mkdir -p $DESTDIR/opt/VirtualBoxKernel/amd64
logcmd cp $UNPACKED_SVR4/SUNWvbox/root/opt/VirtualBox/amd64/{VBoxZoneAccess,VBoxRT.so} $DESTDIR/opt/VirtualBoxKernel/amd64

# ... and the vboxconfig script used by virtualbox-kerneldriver
logcmd cp -r $UNPACKED_SVR4/SUNWvbox/root/opt/VirtualBox/vboxconfig.sh $DESTDIR/opt/VirtualBoxKernel/

# TODO - crossbow woes
# The crossbow driver cries when it tries to install.  Force the old style driver by touching this file. See https://www.virtualbox.org/manual/ch09.html#vboxbowsolaris11
logcmd mkdir -p $DESTDIR/etc
logcmd touch $DESTDIR/etc/vboxinst_vboxflt

# TODO - potentially, plumb hostonly network interface(s).  This also monkeys with NWAM.
# See /opt/VirtualBoxKernel/vboxconfig.sh - postinstall() function
# We'd rather do this in the NGZ's, though, if possible.

make_package vbox-kernel.mog
clean_up



#--------------------------------------------------------------------------#
#                    Part 3: NGZ Userland Binaries
#--------------------------------------------------------------------------#

#PVER=               # Branch (set in config.sh, override here if needed)
PKG=system/virtualbox   # Package name (e.g. library/foo)

SUMMARY="VirtualBox, a virtualization system for x86.  Non-global-zone portion."
DESC="IPS repackaging of SunOS binaries released by Oracle.  Gotchas about this IPS package:  * OmniOS has no X support.  Hence, all the graphical clients are removed.  * Requires execution of the following command on each NGZ that is to use VirtualBox: zonecfg -z <yourzone> 'add device; set match=/dev/vboxdrv; end'"

# This just sets up the dummy install path in $DESTDIR
prep_build

# Start copying files to the installation dir.
logmsg "$PKG - Copying files from unpacked SVR4 package to installation image"

#.....
# Copy everything....
#....
logcmd cp -r $UNPACKED_SVR4/SUNWvbox/root/* $DESTDIR

#.....
# Remove unwanted files...
#.....

# No kernel drivers in the NGZ package.
logcmd rm -rf $DESTDIR/platform
# 64-bit only.  Remove the 32-bit.
logcmd rm -rf $DESTDIR/opt/VirtualBox/i386
# If we ever want the SDK, we'll package it separately.
logcmd rm -rf $DESTDIR/opt/VirtualBox/sdk
# This is desktop integration
logcmd rm -rf $DESTDIR/usr/share/{applications,application-registry,pixmaps,icons}

# TODO - should zoneaccess be running in the NGZ?  If so, 
# need to rename to avoid conflict with manifest packaged in kernel package.
logcmd rm  $DESTDIR/var/svc/manifest/application/virtualbox/virtualbox-zoneaccess.xml

#.....
# Create symlinks
#.....

# It appears that VBox uses two different symlinking schemes.  First, it links
# most user-visible binaries to VBox.sh .

pushd $DESTDIR/opt/VirtualBox > /dev/null
export ONE_TRUE_SCRIPT=VBox.sh
for f in "VBoxAutostart" "VirtualBox" "VBoxManage" "VBoxHeadless" "VBoxBFE"; do 
    ln -s $ONE_TRUE_SCRIPT $f
done
popd > /dev/null

# Note: These files are setuid root, via mog file
# List taken from SVR4 pkgmap
#  /opt/VirtualBox/amd64/VBoxBFE <setuid root>
#  /opt/VirtualBox/amd64/VBoxHeadless <setuid root>
#  /opt/VirtualBox/amd64/VBoxNetAdpCtl <setuid root>
#  /opt/VirtualBox/amd64/VBoxNetDHCP <setuid root>
#  /opt/VirtualBox/amd64/VBoxSDL <setuid root>
#  /opt/VirtualBox/amd64/VirtualBox <setuid root>

# VBox sends the guest additions ISO as an unversioned file, though it very much is version-dependent.
# May want to have multiple versions available.
logcmd mv $DESTDIR/opt/VirtualBox/additions/VBoxGuestAdditions.iso $DESTDIR/opt/VirtualBox/additions/VBoxGuestAdditions-$VER.iso
pushd $DESTDIR/opt/VirtualBox/additions > /dev/null
logcmd ln -s VBoxGuestAdditions-$VER.iso VBoxGuestAdditions.iso
popd > /dev/null


#.....
# Publish Package
#.....


make_package vbox-ngz.mog
clean_up









# Vim hints
# vim:ts=4:sw=4:et:
