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

PROG=myapp      # App name
VER=1.0         # App version
VERHUMAN=$VER   # Human readable version
#PVER=0.1       # Branch (set in config.sh, override here if needed)
PKG=cat/pkg     # Package name (without prefix)
SUMMARY=""      # Change this
DESC=""         # Change this

BUILD_DEPENDS_IPS=
RUN_DEPENDS_IPS="runtime/python-26"

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_package
clean_up
