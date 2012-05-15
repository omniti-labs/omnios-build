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

PROG=pg_amqp
REV=v0.3.0
VER=${REV:1}
PGVER=8411
PKG=omniti/database/postgresql-${PGVER}/$PROG
SUMMARY="$PROG - Publish to AMQP from PostgreSQL Statements"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="omniti/database/postgresql-${PGVER}"

REPOS=github.com
GIT=/usr/bin/git
export PATH=/opt/pgsql${PGVER}/bin:$PATH
export USE_PGXS=1

BUILDARCH=64

download_git() {
    pushd $TMPDIR > /dev/null
    logmsg "Checking for source directory"
    if [ -d $BUILDDIR ]; then
        logmsg "--- removing previous source checkout"
        logcmd rm -rf $BUILDDIR
    fi
    logmsg "Checking code out from subversion"
    logcmd $GIT clone -n git://$REPOS/omniti-labs/$PROG.git $BUILDDIR
    cd $BUILDDIR
    logcmd $GIT checkout $REV
    popd > /dev/null
}

# There is no configuration for this code, so just pretend we did it
configure64() {
    true
}

init
download_git
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
