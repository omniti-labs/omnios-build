#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=DTraceToolkit   # App name
VER=0.99             # App version
PVER=1               # Package Version
PKG=developer/dtrace/toolkit  # Package name (without prefix)
SUMMARY="$PROG ($VER)"
DESC="$PROG - a collection of over 200 useful and documented DTrace scripts"

DEPENDS_IPS="developer/dtrace runtime/perl-510 runtime/python-26"

PREFIX=/opt/DTT

# The toolkit is just scripts, so there is nothing to compile
build_toolkit() {
  logmsg "Installing contents to packaging directory $DESTDIR/$PREFIX"
  logcmd mkdir -p $DESTDIR/$PREFIX || logerr "--- Could not create packaging directory"
  logcmd cp -rpP $TMPDIR/$BUILDDIR/* $DESTDIR/$PREFIX/ || logerr "--- Install failed."
  logcmd rm -f $DESTDIR/$PREFIX/install || logerr "--- Failed to remove the install script that we don't use."
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build_toolkit
fix_permissions
make_package
clean_up
