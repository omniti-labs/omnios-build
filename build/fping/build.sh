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

PROG=fping
VER=2.4b2_to
VERHUMAN=$VER
PKG=omniti/network/fping
SUMMARY="A program to ping hosts in parallel"
DESC="$SUMMARY"

init
download_source $PROG $PROG
patch_source
prep_build
build
make_isa_stub
# This could be made automatic but the version hasn't changed in 10 years...
VER=2.4.2.2
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
