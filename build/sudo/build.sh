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

PROG=sudo
VER=1.8.6p7
VERHUMAN=$VER
PKG=security/sudo
SUMMARY="$PROG - authority delegation tool"
DESC="$SUMMARY"

NO_PARALLEL_MAKE=true

LIBS="-lssp_nonshared"
export LIBS
CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --bindir=/usr/bin --sbindir=/usr/sbin --libexecdir=/usr/lib/sudo"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --libexecdir=/usr/lib/sudo/amd64"
CONFIGURE_OPTS="
    --with-ldap
    --with-project
    --with-timedir=/var/run/sudo
    --with-pam --with-pam-login
    --with-tty-tickets
    --without-insults
    --without-lecture
    --with-ignore-dot
    --with-bsm-audit
"

make_install64() {
    # If this file exists, install will attempt to validate it
    # which will fail becuase we aren't running as root
    logcmd rm -f $DESTDIR/etc/sudoers
    make_install
    # Now cleanup the bits we didn't want (amd64 bins/includes)
    logcmd rm -rf $DESTDIR/usr/bin/amd64
    logcmd rm -rf $DESTDIR/usr/sbin/amd64
    logcmd rm -rf $DESTDIR/usr/include/amd64
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
VER=${VER//p/.}
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
