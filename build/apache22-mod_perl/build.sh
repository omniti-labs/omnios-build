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

PROG=mod_perl
VER=2.0.8
VERHUMAN=$VER
PKG=omniti/server/apache22/mod_perl
SUMMARY="$PROG - embedded Perl $DEPVER interpreter for Apache"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="omniti/library/apr-util omniti/server/apache22 omniti/runtime/perl"
DEPENDS_IPS="omniti/runtime/perl omniti/library/apr-util"

VERLIST="5.14 5.16 5.20"

case $DEPVER in
    5.14)
        DEPENDS_IPS="$DEPENDS_IPS omniti/incorporation/perl-514-incorporation"
        BUILD_DEPENDS_IPS="$BUILD_DEPENDS_IPS omniti/incorporation/perl-514-incorporation"
        ;;
    5.16)
        DEPENDS_IPS="$DEPENDS_IPS omniti/incorporation/perl-516-incorporation"
        BUILD_DEPENDS_IPS="$BUILD_DEPENDS_IPS omniti/incorporation/perl-516-incorporation"
        ;;
    5.20)
        DEPENDS_IPS="$DEPENDS_IPS omniti/incorporation/perl-520-incorporation"
        BUILD_DEPENDS_IPS="$BUILD_DEPENDS_IPS omniti/incorporation/perl-520-incorporation"
        ;;
    "")
        logerr "You must specify a version with -d DEPVER. Valid versions: $VERLIST"
        ;;
esac

BUILDARCH=64
export P64=/opt/OMNIperl/bin/$ISAPART64/perl
export APXS64=/opt/apache22/bin/$ISAPART64/apxs

build64() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 64-bit"
    make_clean
    logmsg "--- Makefile.PL"
    logcmd $P64 Makefile.PL MP_APXS=$APXS64 INSTALLDIRS=vendor || \
        logerr "--- Makefile.PL failed"
    logmsg "--- make"
    logcmd make || logerr "--- make failed"
    logmsg "--- make install"
    logcmd make DESTDIR=${DESTDIR} install || logerr "--- make install failed"
    popd > /dev/null
}

rm_unwanted_files() {
    logmsg "Removing unwanted files from destination directory"
    logcmd find $DESTDIR -name perllocal.pod -exec rm {} \;
    logcmd rm -rf $DESTDIR/opt/OMNIperl/bin
}

init
download_source apache/perl $PROG $VER
patch_source
prep_build
build
rm_unwanted_files
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
