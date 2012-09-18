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

PROG=clearsilver
VER=0.10.5
VERHUMAN=$VER   # Human-readable version
PKG=omniti/templating/clearsilver
SUMMARY="clearsilver templating language"
DESC=$SUMMARY
BUILDARCH=64 # the python we build against is 64bit-only, so this needs to be 64bit too
CONFIGURE_OPTS="--with-python=/opt/python26/bin/python --disable-csharp $CONFIGURE_OPTS"
LDFLAGS="-L/opt/python26/lib/ -R/opt/python26/lib/"
BUILD_DEPENDS_IPS="developer/build/autoconf developer/build/automake-111 omniti/runtime/python-26"
DEPENDS_IPS="omniti/runtime/python-26"

init
download_source $PROG $PROG $VER
patch_source
# because autogen.sh runs configure, we run configure twice. not sure if it's 
# worth the encapsulation break on build() to fix this.
run_autogen
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
