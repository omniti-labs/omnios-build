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

PROG=ircd-ratbox
VER=2.2.9
VERHUMAN=$VER
PKG=omniti/server/irc/ratbox
SUMMARY="Ratbox is an advanced, stable and fast ircd."
DESC="$SUMMARY"

PREFIX=/opt/OMNIratbox
reset_configure_opts

BUILDARCH=64
NO_PARALLEL_MAKE=1

CONFIGURE_OPTS="
    --enable-services
    --enable-small-net
    --with-nicklen=15
    --with-topiclen=640
"

# Work around ratboxes install inanity (it doesn't use mkdir -p)
save_function make_install make_install_orig
make_install() {
    logmsg "--- Making destination bin directory because make install won't"
    logcmd mkdir -p $DESTDIR$PREFIX/bin || \
        logerr "Failed to make destination directory"
    make_install_orig
}

init
download_source ratbox $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
