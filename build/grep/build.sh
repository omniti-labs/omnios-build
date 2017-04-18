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
# Copyright 2016 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=grep       # App name
VER=3.0         # App version
PKG=text/gnu-grep    # Package name (without prefix)
SUMMARY="ggrep - GNU grep utilities"
DESC="$SUMMARY $VER"

DEPENDS_IPS="SUNWcs library/pcre"

BUILDARCH=32
CONFIGURE_OPTS_32="--prefix=$PREFIX
        --sysconfdir=/etc
        --includedir=$PREFIX/include
        --bindir=$PREFIX/bin
        --sbindir=$PREFIX/sbin
        --libdir=$PREFIX/lib
        --libexecdir=$PREFIX/libexec
	--program-prefix=g"

install_license() {
    local LICENSE_FILE
    LICENSE_FILE=$TMPDIR/$BUILDDIR/$1

    if [ -f "$LICENSE_FILE" ]; then
        logmsg "Using $LICENSE_FILE as package license"
        logcmd cp $LICENSE_FILE $DESTDIR/license
    else
        logerr "-- $LICENSE_FILE not found!"
        exit 255
    fi
}

link_up_gnu_sfw() {
    logmsg "Making links in /usr/gnu and /usr/sfw"
    logcmd mkdir -p $DESTDIR/usr/gnu/bin
    logcmd mkdir -p $DESTDIR/usr/gnu/share/man/man1
    logcmd mkdir -p $DESTDIR/usr/sfw/bin
    for cmd in grep egrep fgrep
    do
        logcmd ln -s ../../bin/g$cmd $DESTDIR/usr/gnu/bin/$cmd
        logcmd ln -s ../../../../share/man/man1/g$cmd.1 $DESTDIR/usr/gnu/share/man/man1/$cmd.1
        logcmd ln -s ../../bin/g$cmd $DESTDIR/usr/sfw/bin/g$cmd
    done
}
init
download_source $PROG $PROG $VER
patch_source
prep_build
build
install_license COPYING
make_isa_stub
strip_install
link_up_gnu_sfw
make_package
clean_up
