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

# This are used so people can see what packages get built.. pkg actually publishes
PKG=system/library/iconv/utf-8
PKG=system/library/iconv/utf-8/manual
PKG=system/library/iconv/unicode
PKG=system/library/iconv/extra
PKG=system/library/iconv/xsh4/latin
PKG=system/install/locale
PKG=text/auto_ef
SUMMARY="This isn't used, it's in the makefiles for pkg"
DESC="This isn't used, it's in the makefiles for pkg"

PROG=g11n
VER=0.151005
BUILDNUM=151005
if [[ -z "$PKGPUBLISHER" ]]; then
    logerr "No PKGPUBLISHER specified in config.sh"
    exit # Force it, we're fucked here.
fi

GIT=/usr/bin/git
DMAKE=/opt/sunstudio12.1/bin/dmake

BUILD_DEPENDS_IPS="developer/versioning/git library/idnkit
	library/idnkit/header-idnkit developer/sunstudio12.1"
DEPENDS_IPS=""

clone_source(){
    logmsg "g11n -> $TMPDIR/$BUILDDIR/g11n"
    logcmd mkdir -p $TMPDIR/$BUILDDIR
    pushd $TMPDIR/$BUILDDIR > /dev/null 
    if [[ ! -d g11n ]]; then
        logcmd  $GIT clone -b omni anon@src.omniti.com:~omnios/core/g11n
    fi
    logcmd  cd g11n || logerr "g11n inaccessible"
    SRC=$TMPDIR/$BUILDDIR/g11n
    export SRC
    PKGARCHIVE=$SRC
    export PKGARCHIVE
    popd > /dev/null 
}

build(){
    pushd $TMPDIR/$BUILDDIR/g11n > /dev/null || logerr "Cannot change to src dir"
    logmsg "--- toplevel build"
    logcmd $DMAKE # once for fun
    logcmd $DMAKE # once for glory
    logcmd $DMAKE # once for shame
    logcmd $DMAKE # once to piss me off
    logcmd $DMAKE || logerr "$DMAKE failed"
    logmsg "--- proto install"
    logcmd $DMAKE install || logerr "proto install failed"
    popd > /dev/null
}
install_man(){
    logmsg "--- installing man page"
    logcmd mkdir -p $SRC/proto/i386/fileroot/usr/share/man/man5/ || \
        logerr "could not create destdir for man page"
    logcmd cp files/iconv_en_US.UTF-8.5 \
        $SRC/proto/i386/fileroot/usr/share/man/man5/iconv_en_US.UTF-8.5 || \
        logerr "could not copy man page"
}
package(){
    pushd $TMPDIR/$BUILDDIR/g11n/pkg > /dev/null
    logmsg "--- packaging"
    ISALIST=i386 CC=gcc logcmd $DMAKE \
	CLOSED_BUILD=no \
	L10N_BUILDNUM=$BUILDNUM \
	|| logerr "pkg make failed"
    ISALIST=i386 CC=gcc logcmd $DMAKE publish_pkgs \
	SRC=$SRC \
	CLOSED_BUILD=no \
        L10N_BUILDNUM=$BUILDNUM \
        PKGPUBLISHER_REDIST=$PKGPUBLISHER \
        || logerr "publish failed"
    popd > /dev/null
}

push_pkgs() {
    pushd $SRC > /dev/null
    logmsg "Rebuilding repository metadata"
    logcmd pkgrepo rebuild -s repo.redist || logerr "repo rebuild failed"
    logmsg "Pushing g11n pkgs to $PKGSRVR..."
    logcmd pkgrecv -s repo.redist/ -d $PKGSRVR 'pkg:/*' || logerr "push failed"
    popd > /dev/null
}

init
clone_source
build
install_man
package
push_pkgs
