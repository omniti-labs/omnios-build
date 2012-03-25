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

PROG=cabundle   # App name
VER=1.0         # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=web/ca-bundle  # Package name (without prefix)
SUMMARY="$PROG - Bundle of SSL CA certificates"
DESC="$SUMMARY"

MIRROR=curl.haxx.se

BUILDARCH=32

fetch_pem() {
  logmsg "Fetching PEM file from $MIRROR"
  pushd $TMPDIR > /dev/null
  $WGET -a $LOGFILE http://$MIRROR/ca/cacert.pem ||
    logerr "--- Failed to download PEM file"
  popd > /dev/null
}

install_pem() {
  logmsg "Installing PEM file"
  logcmd mkdir -p $DESTDIR/etc ||
    logerr "--- Unable to create destination directory"
  logmsg "Placing PEM in package root"
  logcmd cp $TMPDIR/cacert.pem $DESTDIR/etc/ ||
    logerr "--- Failed to copy file"
}

init
prep_build
fetch_pem
install_pem
make_package
clean_up
