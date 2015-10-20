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
# Copyright 2015 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=illumos-closed   # App name
VER=5.11        # App version
VERHUMAN=$VER   # Human-readable version
PKG=developer/illumos-closed  # Package name (without prefix)
SUMMARY="$PROG - illumos closed binaries"
DESC="Closed-source binaries required to build an illumos distribution, like OmniOS."

install_closed() {
  logmsg "Creating proto directory"
  #echo "DIagnostics:"
  #echo "TMPDIR == $TMPDIR"
  #echo "DESTDIR == $DESTDIR"
  #echo "BUILDDIR == $BUILDDIR"
  # Bail for now.
  #exit 0
  mkdir -p $DESTDIR/opt/onbld
  cp *.tar.bz2 $DESTDIR/opt/onbld
  pushd $DESTDIR/opt/onbld
  # XXX KEBE ASKS - should we be -v about this? Or more quiet?
  tar xjvpf on-closed-bins.i386.tar.bz2
  tar xjvpf on-closed-bins-nd.i386.tar.bz2
  /bin/rm *.tar.bz2
  popd
}

init
prep_build
install_closed
make_package
clean_up
