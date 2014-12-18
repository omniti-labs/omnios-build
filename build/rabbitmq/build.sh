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

PROG=rabbitmq
VER=3.4.2
VERHUMAN=$VER
PKG=omniti/network/rabbitmq
SUMMARY="RabbitMQ Message Queue Broker"
DESC="$SUMMARY"

PREFIX=/opt/rabbitmq
reset_configure_opts
BUILDDIR=${PROG}_server-${VER}

DEPENDS_IPS="omniti/runtime/erlang text/gnu-sed"

build() {
    install_rabbitmq_server
    make_scripts_use_bash
}

make_scripts_use_bash() {
    logmsg "Fixing script to use bash and explicit erl"
    for i in $DESTDIR/$PREFIX/sbin/*; do
        gsed -i -e '1s+#!/bin/sh+#!/bin/bash+' $i 
        gsed -i -e 's+erl+/opt/omni/bin/erl+' $i 
    done
}

install_rabbitmq_server() {
    logmsg "Installing rabbitmq-server files"
    logcmd mkdir -p $DESTDIR/$PREFIX
    logcmd mkdir -p $DESTDIR/$PREFIX/var/log/rabbitmq
    logcmd mkdir -p $DESTDIR/$PREFIX/var/lib/rabbitmq
    logcmd cp -r -p $TMPDIR/$BUILDDIR/* $DESTDIR/$PREFIX/ || \
        logerr "Failed to install rabbitmq-server files"
}

service_configs() {
    logmsg "Installing SMF"
    logcmd mkdir -p $DESTDIR/lib/svc/manifest/network/
    logcmd cp $SRCDIR/files/rabbitmq.xml \
        $DESTDIR/lib/svc/manifest/network/rabbitmq.xml
    logmsg "Installing configs"
    logcmd mkdir -p $DESTDIR/$PREFIX/etc/rabbitmq
    logcmd cp $SRCDIR/files/enabled_plugins $DESTDIR/$PREFIX/etc/rabbitmq/
}

init
download_source $PROG rabbitmq-server-generic-unix-${VER}
patch_source
prep_build
build
service_configs
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
