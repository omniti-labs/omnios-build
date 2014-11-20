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
# Copyright 2014 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=milter-greylist 
VER=4.4.3
PKG=omniti/network/smtp/milter-greylist            # Package name (e.g. library/foo)
SUMMARY="milter-greylist is a stand-alone milter that implements the greylist filtering method"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="developer/lexer/flex developer/parser/bison service/network/smtp/sendmail"
DEPENDS_IPS="service/network/smtp/sendmail"

BUILDARCH=32
NO_PARALLEL_MAKE=true

CONFIGURE_OPTS="$CONFIGURE_OPTS --enable-spamassassin --enable-postfix --enable-dnsrbl --enable-mx --enable-stdio-hack --enable-p0f --enable-p0f3 --enable-p0f306"

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
