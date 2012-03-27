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

PROG=libpcap
VER=1.2.1
VERHUMAN=$VER
PVER=0.1
PKG=system/library/pcap
SUMMARY="libpcap - a packet capture library"
DESC="$SUMMARY"

CONFIGURE_OPTS="$CONFIGURE_OPTS --mandir=/usr/share/man"

save_function configure32 configure32_orig
save_function configure64 configure64_orig
configure32(){
    configure32_orig
    gsed -i 's/#define HAVE_NETPACKET_PACKET_H 1//;' config.h
}
configure64(){
    configure64_orig
    gsed -i 's/#define HAVE_NETPACKET_PACKET_H 1//;' config.h
}
fixup_man3(){
    mv $DESTDIR/usr/share/man/man3 $DESTDIR/usr/share/man/man3pcap
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
run_autoconf
build
make_isa_stub
fixup_man3
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
