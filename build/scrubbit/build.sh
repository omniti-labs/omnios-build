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

PROG=scrubbit
VER=26
VERHUMAN="svn-r$VER"
PKG=omniti/system/storage/scrubbit
SUMMARY="$PROG - Periodic, automatic zpool scrubber"
DESC="$SUMMARY"

REPOS=labs.omniti.com
SVN=/opt/omni/bin/svn

download_svn() {
    pushd $TMPDIR > /dev/null
    logmsg "Checking for source directory"
    if [ -d $BUILDDIR ]; then
        logmsg "--- removing previous source checkout"
        logcmd rm -rf $BUILDDIR
    fi
    logmsg "Checking code out from subversion"
    logcmd $SVN co -r$VER https://$REPOS/$PROG/trunk $BUILDDIR
    popd > /dev/null
}

build() {
    logmsg "Installing files"

    logmsg "--- Sample config file"
    logcmd mkdir -p $DESTDIR/$PREFIX/etc
    logcmd cp $TMPDIR/$BUILDDIR/scrubbit.conf.sample $DESTDIR/$PREFIX/etc

    logmsg "--- Perl files"
    logcmd mkdir -p $DESTDIR/$PREFIX/share/$PROG
    logcmd cp $TMPDIR/$BUILDDIR/* $DESTDIR/$PREFIX/share/$PROG

    logmsg "--- Fixing default config file location"
    sed "s+CONF=\"scrubbit.conf\"+CONF=\"$PREFIX/etc/scrubbit.conf\"+" \
        $TMPDIR/$BUILDDIR/$PROG > $DESTDIR/$PREFIX/share/$PROG/$PROG

    logmsg "--- Script in $PREFIX/bin"
    logcmd mkdir -p $DESTDIR/$PREFIX/bin
    cat >$DESTDIR/$PREFIX/bin/$PROG <<EOF
#!/bin/sh
perl -I$PREFIX/share/$PROG $PREFIX/share/$PROG/$PROG "\$@"
EOF
    logcmd chmod +x $DESTDIR/$PREFIX/bin/$PROG
}

init
download_svn
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
