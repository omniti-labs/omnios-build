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

PROG=gettext                  # App name
VER=0.19.8.1                  # App version
PKG=text/gnu-gettext          # Package name (without prefix)
SUMMARY="gettext - GNU gettext utility"
DESC="GNU gettext - GNU gettext utility ($VER)"

NO_PARALLEL_MAKE=1
BUILDARCH=32

DEPENDS_IPS="developer/macro/gnu-m4"

CONFIGURE_OPTS="--infodir=$PREFIX/share/info
	--disable-java
	--disable-libasprintf
	--without-emacs
	--disable-openmp
	--disable-static
	--disable-shared
	--bindir=/usr/bin"

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

make_links() {
    logmsg "Creating GNU symlinks"
    logcmd mkdir -p $DESTDIR/$PREFIX/gnu/bin
    logcmd mkdir -p $DESTDIR/$PREFIX/gnu/share/man/man1
    for file in gettext msgfmt xgettext
    do
        logcmd mv $DESTDIR/$PREFIX/bin/$file $DESTDIR/$PREFIX/bin/g$file
        logcmd mv $DESTDIR/$PREFIX/share/man/man1/$file.1 $DESTDIR/$PREFIX/share/man/man1/g$file.1
        logcmd ln -s ../../bin/g$file $DESTDIR/$PREFIX/gnu/bin/$file
        logcmd ln -s ../../../../share/man/man1/g$file.1 $DESTDIR/$PREFIX/gnu/share/man/man1/$file
    done
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
install_license COPYING
make_isa_stub
make_links
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
