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
# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=phantomjs
VER=1.9.0
VERHUMAN=$VER
PKG=omniti/runtime/phantomjs
SUMMARY="Sriptable Headless WebKit"
DESC="$SUMMARY"

IPS_DEPENDS="freetype2 fontconfig g++-4-runtime"

build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null || logerr "Cannot change to builddir"

    logmsg "--- Building phantomjs"
    logcmd ./build.sh --confirm || logerr "Build failed"
    logcmd /bin/gstrip -s bin/phantomjs || logerr "could not strip binary"

    logmsg "--- Installing phantomjs"
    logcmd mkdir -p $DESTDIR/$PREFIX/share/phantomjs || \
        logerr "share create failed"
    logcmd cp -r examples/ $DESTDIR/$PREFIX/share/phantomjs/ || \
        logerr "could not install examples"
    logcmd chmod 444 $DESTDIR/$PREFIX/share/phantomjs/examples/* || \
        logerr "could not chmod examples"
    logcmd mkdir -p $DESTDIR/$PREFIX/bin || logerr "bindir create failed"
    logcmd /usr/bin/install -m 0555 bin/phantomjs $DESTDIR/$PREFIX/bin/phantomjs || \
        logerr "could not install phantomjs"

    popd >/dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
