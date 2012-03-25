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

PROG=pycurl     # App name
VER=7.19.0      # App version
PVER=0.151002   # Package Version
PKG=library/python-2/pycurl # Package name (without prefix)
SUMMARY="Python bindings for libcurl"
DESC="PycURL provides a thin layer of Python bindings on top of libcurl."

DEPENDS_IPS="runtime/python-26 library/security/openssl@1.0.0 web/curl@7.24"

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
VER=7.19.0.1
make_package
clean_up
