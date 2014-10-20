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

SHELL=/usr/bin/bash
export SHELL

RELEASE_DATE=nightly # This is overridden by the checkout

# Load support functions
. ../../lib/functions.sh

PROG=omnios    # App name
VER=$RELVER    # App version
PVER=1         # Package Version (numeric only)

PKG=illumos-gate # Package name (without prefix)
SUMMARY="$PROG" # A short summary of what the app is, starting with its name
DESC="$SUMMARY -- Illumos and some special sauce." # Longer description

#all of the ips depends should be available from OmniTI repos

BUILD_DEPENDS_IPS="developer/astdev developer/build/make developer/build/onbld developer/gcc44 developer/java/jdk developer/lexer/flex developer/object-file developer/parser/bison library/glib2 library/libxml2 library/libxslt library/nspr/header-nspr library/perl-5/xml-parser library/security/trousers runtime/perl runtime/perl-64 runtime/perl/manual system/library/install system/library/dbus system/library/libdbus system/library/libdbus-glib system/library/mozilla-nss/header-nss system/management/snmp/net-snmp text/gnu-gettext sunstudio12.1"

GIT=git

USE_SYSTEM_SSL_HEADERS="TRUE"

PKGPREFIX=""
PREFIX=""
TMPDIR=/code	# This directory must be writable as your non-root user
BUILDDIR=$USER-$PROG-$VER
CODEMGR_WS=$TMPDIR/$BUILDDIR/illumos-omnios

#Since these variables are used in a sed statment make sure to escape properly
ILLUMOS_NO="NIGHTLY\_OPTIONS=\'\-nDCmpr\'"
ILLUMOS_CODEMGR_WS="CODEMGR\_WS=\/code\/$BUILDDIR\/illumos\-omnios"
#ILLUMOS_CLONE_WS="CLONE\_WS=\'ssh:\/\/anonhg@hg.illumos.org\/illumos\-gate\'"
ILLUMOS_CLONE_WS="CLONE\_WS=\'anon@src.omniti.com:~omnios\/core\/illumos\-omnios\'"

ILLUMOS_PKG_REDIST="PKGPUBLISHER\_REDIST=\'omnios\'"

#these variables are appended to the end of the script so no need to escape
ILLUMOS_GNUC="export __GNUC=''"
ILLUMOS_GNUC4="export __GNUC4=''"
ILLUMOS_NO_SHADOW="export CW_NO_SHADOW=1"
ILLUMOS_GCC_ROOT='export GCC_ROOT="/opt/gcc-4.4.4"'
ILLUMOS_CW_GCC_DIR='export CW_GCC_DIR="$GCC_ROOT/bin"'
ILLUMOS_BUILDNUM="ONNV_BUILDNUM=$VER; export ONNV_BUILDNUM;"
ILLUMOS_MULTI_PROTO="export MULTI_PROTO=yes"

sunstudio_location() {
    logmsg "Ensuring that Sun Studio is where Illumos thinks it is..."
    if [[ -L /opt/SUNWspro ]]; then
	logmsg "--- fake SUNWspro link exists, good"
    else
	logmsg "--- making fake SUNWspro directory"
	logcmd sudo ln -s /opt/sunstudio12.1 /opt/SUNWspro || \
	    logerr "--- Error: failed to make link"
    fi
}

#In order for the clone to work while running as root, you must have ssh'ed into the box with agent forwarding turned on.  Also the sudo'er file must either have the default, group, or user set to allow SSL_AUTH_SOCK.

clone_source(){
    logmsg "Creating build dir $TMPDIR/$BUILDDIR"
    logcmd mkdir -p $TMPDIR/$BUILDDIR || \
        logerr "--- Failed to create build dir $TMPDIR/$BUILDDIR"
    logmsg "Entering $TMPDIR/$BUILDDIR"
    pushd $TMPDIR/$BUILDDIR > /dev/null 
    if [ -d illumos-omnios ]; then
        logmsg "OMNI Illumos Source in place. Using existing workspace."
    else
        logmsg "Cloning OMNI Illumos Source..."
        logcmd  $GIT clone anon@src.omniti.com:~omnios/core/illumos-omnios || \
            logerr "--- Failed to clone source"
    fi
    pushd illumos-omnios 
    ILLUMOS_VERSION="VERSION=\'omnios\-`$GIT log --pretty=format:'%h' -n 1`'" 
    RELEASE_DATE=`$GIT show --format=format:%ai | awk '{print $1; exit;}' | tr - .` 
    echo $ILLUMOS_VERSION
    popd > /dev/null 
    logmsg "Leaving $TMPDIR/$BUILDDIR"
    popd > /dev/null 
}

build_tools(){
    logmsg "Entering $CODEMGR_WS"
    pushd $CODEMGR_WS > /dev/null
    logmsg "Building extra tools needed for illumos pkgs..."
    logcmd ln -s usr/src/tools/scripts/bldenv.sh .
    logcmd ksh93 bldenv.sh -d illumos.sh -c "cd usr/src && dmake setup" 
    logmsg "Leaving $CODEMGR_WS"
    popd > /dev/null
}

modify_build_script() {
    logmsg "Entering $CODEMGR_WS"
    pushd $CODEMGR_WS > /dev/null
    logmsg "Changing illumos.sh variables to what we want them to be..."
    logcmd cp usr/src/tools/env/illumos.sh .    
    logcmd /usr/bin/gsed -i -e 's/^.*export NIGHTLY_OPTIONS.*/export '$ILLUMOS_NO'/g;s/^.*export CODEMGR_WS=.*/export '$ILLUMOS_CODEMGR_WS'/g;s/^.*export CLONE_WS=.*/export '$ILLUMOS_CLONE_WS'/g;s/^.*export PKGPUBLISHER_REDIST=.*/export '$ILLUMOS_PKG_REDIST'/g;s/^.*export VERSION=.*/export '$ILLUMOS_VERSION'/g;/^.*GNUC=.*/d;/^.*CW_NO_SHADOW=.*/d;/^.*ONNV_BUILDNUM=.*/d' illumos.sh || \
        logerr "/usr/bin/gsed failed"
    logcmd `echo $ILLUMOS_GNUC >> illumos.sh` 
    logcmd `echo $ILLUMOS_GNUC4 >> illumos.sh` 
    logcmd `echo $ILLUMOS_GCC_ROOT >> illumos.sh` 
    logcmd `echo $ILLUMOS_CW_GCC_DIR >> illumos.sh`
    logcmd `echo $ILLUMOS_NO_SHADOW >> illumos.sh`
    logcmd `echo $ILLUMOS_BUILDNUM >> illumos.sh`
    logcmd `echo $ILLUMOS_MULTI_PROTO >> illumos.sh`
    logcmd `echo RELEASE_DATE=$RELEASE_DATE >> illumos.sh`
    logmsg "Leaving $CODEMGR_WS"
    popd > /dev/null

}

closed_bins() {
    logmsg "Entering $CODEMGR_WS"
    pushd $CODEMGR_WS > /dev/null
    logmsg "Getting Closed Source Bins..."
    for bin in on-closed-bins.i386.tar.bz2 on-closed-bins-nd.i386.tar.bz2 ; do
	if [[ ! -f $bin ]]; then
            logcmd curl -s -O http://mirrors.omniti.com/illumos-gate/$bin
	fi
    	logcmd tar xvpf $bin
    done
    logmsg "Leaving $CODEMGR_WS"
    popd > /dev/null 
}

build_pkgs() {
    logmsg "Entering $CODEMGR_WS"
    pushd $CODEMGR_WS > /dev/null
    logmsg "Building illumos pkgs..."
    logcmd cp usr/src/tools/scripts/nightly.sh .
    logcmd chmod +x nightly.sh
    logcmd ./nightly.sh illumos.sh || logerr "Nightly failed"
    logmsg "Leaving $CODEMGR_WS"
    popd > /dev/null
}

push_pkgs() {
    logmsg "Entering $CODEMGR_WS"
    pushd $CODEMGR_WS > /dev/null
    logmsg "Pushing illumos pkgs to $PKGSRVR..."
    if [[ -z $BATCH ]]; then
        logmsg "Intentional pause: Last chance to sanity-check before publication!"
        ask_to_continue
    fi
    logcmd pkgrecv -s packages/i386/nightly-nd/repo.redist/ -d $PKGSRVR 'pkg:/*'
    logmsg "Leaving $CODEMGR_WS"
    popd > /dev/null
}

init
prep_build
if [ -d ${PREBUILT_ILLUMOS:-/dev/null} ]; then
    wait_for_prebuilt
    # Check for existing packages, or for freshly built ones if we pwaited.
    if [ -d $PREBUILT_ILLUMOS/packages/i386/nightly-nd/repo.redist ]; then
        logmsg "Using illumos-omnios pre-compiled at $PREBUILT_ILLUMOS"
        CODEMGR_WS=$PREBUILT_ILLUMOS
        push_pkgs
    else
        logmsg "No $PREBUILT_ILLUMOS/packages/i386/nightly-nd/repo.redist"
        if [[ -z $BATCH ]]; then
            ask_to_continue
        fi
    fi
else
    sunstudio_location
    clone_source
    modify_build_script
    closed_bins
    build_tools
    build_pkgs
    push_pkgs
fi
clean_up
