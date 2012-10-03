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

# Development hook - if we are under VirtualBox, assume we 
# should just publish to the local repo
if svcs | grep vboxservice > /dev/null; then 
    PKGSRVR=http://localhost:888
fi

PROG=apache-tomcat      # App name
VER=7.0.30       # App version
COMMONS_DAEMON_VER=1.0.10  # jsvc version
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=omniti/server/tomcat7            # Package name (e.g. library/foo)
SUMMARY="Apache Tomcat Java Web Server / Servlet Container"      # One-liner, must be filled in
DESC=$SUMMARY         # Longer description, must be filled in
PREFIX=/opt/tomcat7

BUILD_DEPENDS_IPS="developer/java/jdk" 
DEPENDS_IPS="runtime/java" 
JAVA_HOME=/usr/java
export JAVA_HOME

# Find mirrors at http://tomcat.apache.org/download-70.cgi
# Example URL:
# http://mirror.symnds.com/software/Apache/tomcat/tomcat-7/v7.0.30/bin/apache-tomcat-7.0.30.tar.gz
MIRROR=mirror.symnds.com

# Note that this is a BINARY distribution - so we don't have to "build" it per se
# However, we DO have to compile the daemon runner, jsvc
DLDIR=software/Apache/tomcat/tomcat-7/v$VER/bin


init
download_source $DLDIR $PROG $VER

# No patches
patch_source
prep_build

# Need to build the jsvc daemon
# http://tomcat.apache.org/tomcat-7.0-doc/setup.html#Unix_daemon

tomcat_copy_install() {
    mkdir -p $DESTDIR$PREFIX
    cp -r $TMPDIR/$BUILDDIR/* $DESTDIR$PREFIX

    # Delete the source for the jsvcs builds, if any
    rm -rf $DESTDIR$PREFIX/bin/commons-daemon-$COMMONS_DAEMON_VER-native-src-*

    # No, we don't want logs to be under opt
    mkdir -p $DESTDIR/var/log/tomcat7
    rm -rf $DESTDIR$PREFIX/logs
    ln -s ../../var/log/tomcat7 $DESTDIR$PREFIX/logs 

    # Copy in sample manifest file
    mkdir -p $DESTDIR/var/svc/manifest/network/tomcat7
    cp  $SRCDIR/files/tomcat7.xml $DESTDIR/var/svc/manifest/network/tomcat7
    
}

build32() {
    pushd $TMPDIR/$BUILDDIR/bin > /dev/null
    rm -rf $TMPDIR/$BUILDDIR/bin/commons-daemon-$COMMONS_DAEMON_VER-native-src
    rm -rf $TMPDIR/$BUILDDIR/bin/commons-daemon-$COMMONS_DAEMON_VER-native-src-32    
    tar xzf commons-daemon-native.tar.gz
    mv $TMPDIR/$BUILDDIR/bin/commons-daemon-$COMMONS_DAEMON_VER-native-src $TMPDIR/$BUILDDIR/bin/commons-daemon-$COMMONS_DAEMON_VER-native-src-32
    pushd $TMPDIR/$BUILDDIR/bin/commons-daemon-$COMMONS_DAEMON_VER-native-src-32/unix
    logmsg "Building 32-bit jsvc"
    export ISALIST="$ISAPART"
    sh support/buildconf.sh
    ./configure
    make_prog32

    # Do the install of the arch-neutral code
    tomcat_copy_install
        
    # and then install the 32-bit jsvc
    mkdir -p $DESTDIR$PREFIX/bin/i386-pc-solaris2.11
    cp jsvc $DESTDIR$PREFIX/bin/i386-pc-solaris2.11

    # And copy it in as bin
    cp jsvc $DESTDIR$PREFIX/bin/jsvc

    popd > /dev/null
    popd > /dev/null
    unset ISALIST
    export ISALIST
}

# NOTE: Though this works, using it is broken, because the java included with the system is 32-bit only
build64() {
    pushd $TMPDIR/$BUILDDIR/bin > /dev/null
    rm -rf $TMPDIR/$BUILDDIR/bin/commons-daemon-$COMMONS_DAEMON_VER-native-src
    rm -rf $TMPDIR/$BUILDDIR/bin/commons-daemon-$COMMONS_DAEMON_VER-native-src-64
    tar xzf commons-daemon-native.tar.gz
    mv $TMPDIR/$BUILDDIR/bin/commons-daemon-$COMMONS_DAEMON_VER-native-src $TMPDIR/$BUILDDIR/bin/commons-daemon-$COMMONS_DAEMON_VER-native-src-64
    pushd $TMPDIR/$BUILDDIR/bin/commons-daemon-$COMMONS_DAEMON_VER-native-src-64/unix
    logmsg "Building 64-bit jsvc"
    make_clean
    sh support/buildconf.sh
    configure64
    make_prog64

    # Do the install of the arch-neutral code
    tomcat_copy_install
        
    # and then install the 64-bit jsvc
    mkdir -p $DESTDIR$PREFIX/bin/amd64
    cp jsvc $DESTDIR$PREFIX/bin/amd64

    popd > /dev/null
    popd > /dev/null
}

build() {
    if [[ $BUILDARCH == "32" || $BUILDARCH == "both" ]]; then
        build32
    fi
    if [[ $BUILDARCH == "64" || $BUILDARCH == "both" ]]; then
        logerr "Currently cannot build 64-bit version of tomcat - (only 32-bit java available)"
        #build64
    fi
}

build
#make_isa_stub # Just copying the 32-bit version
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
