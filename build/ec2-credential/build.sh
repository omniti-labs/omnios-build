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

PROG=ec2-credential
VER=1.0
VERHUMAN=$VER
PKG=system/management/ec2-credential
SUMMARY="Service that handles Amazon EC2 ssh key setup at boot time"
DESC="$SUMMARY"

DEPENDS_IPS="shell/bash"

drop_files() {
    logmsg "Installing files"
    logcmd mkdir -p ${DESTDIR}${PREFIX}/bin || \
        logerr "Could not make dir ${DESTDIR}${PREFIX}/bin"
    logcmd cp -p $SRCDIR/files/install-ec2-credential ${DESTDIR}${PREFIX}/bin/ || \
        logerr "Failed to copy install-ec2-credential"
    logcmd mkdir -p ${DESTDIR}/lib/svc/manifest/system || \
        logerr "Could not make dir ${DESTDIR}/lib/svc/manifest/system"
    logcmd cp -p $SRCDIR/files/ec2-credential.xml ${DESTDIR}/lib/svc/manifest/system/ || \
        logerr "Failed to copy ec2-credential.xml"
}

init
prep_build
drop_files
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
