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

# Package Configuration

PROG=resmon
VER=git          # The real version is set in download_git()
PKG=omniti/monitoring/resmon
SUMMARY="Resmon Perl-Based Metric Collector"
DESC="Resmon is an extensible monitoring agent that reports data over HTTP."
DEPENDS_IPS="omniti/runtime/perl"
BUILDARCH=64
PREFIX=/opt/resmon

# 
GIT=/usr/bin/git
PATH=$PATH:/opt/omni/bin

download_git() {
    REPOS=$1
    BUILDDIR=$2
    REV=$3
    # Create TMPDIR if it doesn't exist
    if [[ ! -d $TMPDIR ]]; then
        logmsg "Specified temp directory $TMPDIR does not exist.  Creating it now."
        logcmd mkdir -p $TMPDIR
    fi
    pushd $TMPDIR > /dev/null
    logmsg "Checking for source directory"
    if [ -d $BUILDDIR ]; then
        logmsg "Removing source directory"
        rm -rf $BUILDDIR
    fi
    if [ ! -d $BUILDDIR ]; then
        logmsg "Checking code out from $REPOS"
        logcmd $GIT clone $REPOS $BUILDDIR
    fi
    pushd $BUILDDIR > /dev/null
    $GIT pull
    if [ -n $REV ]; then $GIT checkout $REV; fi
    REV=`$GIT log -1  --format=format:%at`
    if [[ $VER == "git" ]]; then
        VER="0.1.$REV"
    fi
    REVDATE=`echo $REV | gawk '{ print strftime("%c %Z",$1) }'`
    popd > /dev/null
    popd > /dev/null
}

# Nothing to configure, it's just node scripts
configure64() {
    true
}

# There is no Makefile for Resmon, just rsync
build64() {
    logmsg "Installing resmon files"
    logcmd mkdir -p $DESTDIR/$PREFIX
    logcmd rsync -r $TMPDIR/$BUILDDIR/* $DESTDIR/$PREFIX/ || \
        logerr "Failed to install resmon files"
}

init
download_git git://github.com/omniti-labs/resmon.git $PROG-$VER
VERHUMAN="(checkout as of $REVDATE)"
patch_source
prep_build

build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:

