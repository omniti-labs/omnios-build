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

PROG=openldap   # App name
VER=2.4.40
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=omniti/network/openldap-server # Package name (e.g. library/foo)
SUMMARY="LDAP Directory Daemon"      # One-liner, must be filled in
DESC="OpenLDAP Software is an Open Source suite of directory software developed by the Internet community."         # Longer description, must be filled in

CONFIGURE_OPTS="
	--enable-syslog 
	--enable-dynamic 
	--enable-slapd 
	--enable-cleartext 
	--enable-spasswd 
	--enable-rewrite 
	--enable-mdb 
	--enable-hdb=no 
	--enable-bdb=no 
	--enable-monitor 
	--enable-overlays 
	--with-cyrus-sasl 
	--with-threads 
	--with-tls=openssl"

make_prog() {
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    logmsg "--- make depend"
    logcmd $MAKE depend || \
	logerr "--- Make depend failed"
    logmsg "--- make"
    logcmd $MAKE $MAKE_JOBS || \
        logerr "--- Make failed"
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
