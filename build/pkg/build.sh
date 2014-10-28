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
PKG=package/pkg
PKG=system/zones/brand/ipkg
SUMMARY="This isn't used, it's in the makefiles for pkg"
DESC="This isn't used, it's in the makefiles for pkg"

PROG=pkg
VER=omni
BUILDNUM=$RELVER
if [[ -z "$PKGPUBLISHER" ]]; then
    logerr "No PKGPUBLISHER specified. Check lib/site.sh?"
    exit # Force it, we're fucked here.
fi

GIT=/usr/bin/git
# On a running system, these are in /usr/include/.
HEADERS="libbrand.h libuutil.h libzonecfg.h"
BRAND_CFLAGS="-I./gate-include"

BUILD_DEPENDS_IPS="developer/versioning/git developer/versioning/mercurial system/zones/internal"
DEPENDS_IPS="runtime/python-26@2.6.7"

crib_headers(){
    # Use PREBUILT_ILLUMOS if available, otherwise, just pull off the
    # running system.
    mkdir -p $TMPDIR/$BUILDDIR/pkg/src/brand/gate-include ||
        logerr "Cannot create include stub directory"
    for hdr in $HEADERS; do
	# first just copy from the running system
	cp /usr/include/$hdr $TMPDIR/$BUILDDIR/pkg/src/brand/gate-include/. ||
	    logerr "Copy $hdr from /usr/include failed"
	# then see if we can get the more recent PREBUILT_ILLUMOS version...
	cp $PREBUILT_ILLUMOS/proto/root_`uname -p`/usr/include/$hdr \
	    $TMPDIR/$BUILDDIR/pkg/src/brand/gate-include/. ||
	    logmsg "Copy $hdr from PREBUILT_ILLUMOS ($PREBUILT_ILLUMOS) failed. Using /usr/include version."
    done
}

PKG_SOURCE_REPO=${PKG_SOURCE_REPO:-anon@src.omniti.com:~omnios/core/pkg}

clone_source(){
    logmsg "pkg -> $TMPDIR/$BUILDDIR/pkg"
    logcmd mkdir -p $TMPDIR/$BUILDDIR
    pushd $TMPDIR/$BUILDDIR > /dev/null 
    if [[ ! -d pkg ]]; then
        logcmd $GIT clone $PKG_SOURCE_REPO pkg
    fi
    pushd pkg > /dev/null || logerr "no source"
    logcmd $GIT pull || logerr "failed to pull"
    logcmd $GIT checkout r$RELVER || logmsg "No r$RELVER branch, using master."
    popd > /dev/null
    popd > /dev/null 
}

build(){
    pushd $TMPDIR/$BUILDDIR/pkg/src > /dev/null || logerr "Cannot change to src dir"
    find . -depth -name \*.mo -exec touch {} \;
    touch `find gui/help -depth -name \*.in | sed -e 's/\.in$//'`
    pushd $TMPDIR/$BUILDDIR/pkg/src/brand > /dev/null
    logmsg "--- brand subbuild"
    logcmd make clean
    ISALIST=i386 CC=gcc CFLAGS="$BRAND_CFLAGS" logcmd make \
        CODE_WS=$TMPDIR/$BUILDDIR/pkg || logerr "brand make failed"
    popd
    logmsg "--- toplevel build"
    logcmd make clean
    ISALIST=i386 CC=gcc logcmd make \
        CODE_WS=$TMPDIR/$BUILDDIR/pkg || logerr "toplevel make failed"
    logmsg "--- proto install"
    ISALIST=i386 CC=gcc logcmd make install \
        CODE_WS=$TMPDIR/$BUILDDIR/pkg || logerr "proto install failed"
    popd > /dev/null
}
package(){
    pushd $TMPDIR/$BUILDDIR/pkg/src/pkg > /dev/null
    logmsg "--- packaging"
    logcmd make clean
    ISALIST=i386 CC=gcc logcmd make \
        CODE_WS=$TMPDIR/$BUILDDIR/pkg \
        BUILDNUM=$BUILDNUM || logerr "pkg make failed"
    ISALIST=i386 CC=gcc logcmd make publish-pkgs \
        CODE_WS=$TMPDIR/$BUILDDIR/pkg \
        BUILDNUM=$BUILDNUM \
        PKGSEND_OPTS="" \
        PKGPUBLISHER=$PKGPUBLISHER \
        PKGREPOTGT="" \
        PKGREPOLOC="$PKGSRVR" \
        || logerr "publish failed"
    popd > /dev/null
}

init
clone_source
# This is hugely expensive
# We've committed these files to pkg, but they need to be kept up to date
#crib_headers
build
package
