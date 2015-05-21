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
# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=openssh
VER=6.7p1
VERHUMAN=$VER
PKG=network/openssh
SUMMARY="OpenSSH Client and utilities"
DESC="OpenSSH Secure Shell protocol Client and associated Utilities"

GLOBAL_DEPENDS="library/security/openssl@1.0.2 library/zlib@1.2 system/library system/library/g++-5-runtime"

BUILDARCH=32
# Since we're only building 32-bit, don't bother with isaexec subdirs
CONFIGURE_OPTS_32="
    --prefix=$PREFIX
    --sysconfdir=/etc/ssh
    --includedir=$PREFIX/include
    --bindir=$PREFIX/bin
    --sbindir=$PREFIX/sbin
    --libdir=$PREFIX/lib
    --libexecdir=$PREFIX/libexec
    "
# Feature choices
CONFIGURE_OPTS="
    --with-solaris-contracts
    --with-solaris-projects
    --with-tcp-wrappers
    --with-ssl-engine
    --with-pam
    "

install_smf() {
    logmsg "Installing SMF components"
    logcmd mkdir -p $DESTDIR/lib/svc/manifest/network || \
        logerr "--- Failed to create manifest directory"
    logcmd cp $SRCDIR/ssh.xml $DESTDIR/lib/svc/manifest/network/ || \
        logerr "--- Failed to copy manifest file"
    logcmd mkdir -p $DESTDIR/lib/svc/method || \
        logerr "--- Failed to create method directory"
    logcmd cp $SRCDIR/method-sshd $DESTDIR/lib/svc/method/sshd || \
        logerr "--- Failed to copy method script"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build

# Remove the letter from VER for packaging
VER=${VER//p/.}

# Client package
DEPENDS_IPS="-network/ssh -network/ssh/ssh-key $GLOBAL_DEPENDS"
make_package client.mog

# Server package
PKG=network/openssh-server
PKGE=$(url_encode $PKG)
SUMMARY="OpenSSH Server"
DESC="OpenSSH Secure Shell protocol Server"
DEPENDS_IPS="-service/network/ssh network/openssh $GLOBAL_DEPENDS"
install_smf
make_package server.mog

clean_up

# Vim hints
# vim:ts=4:sw=4:et:
