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
# Copyright (c) 2014, 2016 by Delphix. All rights reserved.
#
# Load support functions
. ../../lib/functions.sh

PROG=fio        # App name
VER=2.12        # App version
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=benchmark/fio # Package name (e.g. library/foo)
SUMMARY="Flexible IO Tester" # One-liner, must be filled in
DESC="Flexible IO Tester" # Longer description, must be filled in
PATH=/usr/gnu/bin:/opt/csw/bin:$PATH # The source will only unpack using GNU tar
NOSCRIPTSTUB=1  # Don't make isa wrappers for scripts

BUILD_DEPENDS_IPS=
RUN_DEPENDS_IPS=

CONFIGURE_OPTS=
CONFIGURE_OPTS_32=
CONFIGURE_OPTS_64="--extra-cflags=-m64"

make_install32() {
	logcmd $MAKE DESTDIR=${DESTDIR} bindir="/usr/bin/i386" install || \
	    logerr "--- Make install failed"
}

make_install64() {
	logcmd $MAKE DESTDIR=${DESTDIR} bindir="/usr/bin/amd64" install || \
	    logerr "--- Make install failed"
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
