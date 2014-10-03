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

PROG=pkg-config
VER=0.28
VERHUMAN=$VER
PKG=developer/pkg-config
SUMMARY="A tool for generating compiler command line options"
DESC="pkg-config is a helper tool used when compiling applications and libraries that helps you insert the correct compiler options on the command line, rather than hard-coding values on where to find libraries."

BUILD_DEPENDS_IPS=
RUN_DEPENDS_IPS=

CONFIGURE_OPTS="--with-internal-glib"

init
download_source $PROG $PROG $VER
prep_build
build
make_isa_stub
make_package
clean_up
