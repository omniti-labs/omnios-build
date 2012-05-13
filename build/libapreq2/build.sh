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

PROG=libapreq2
VER=2.13
VERHUMAN=$VER
PKG=omniti/library/libapreq2
SUMMARY="$PROG - Apache HTTP Request Library"
DESC="libapreq is a shared library with associated modules for manipulating client request data via the Apache API. It also includes language bindings for Perl (Apache::Request and Apache::Cookie)."

BUILD_DEPENDS_IPS="omniti/server/apache22/mod_perl"
DEPENDS_IPS="omniti/server/apache22"

# Valid OMNIperl versions
VERLIST="5.8.8 5.14.2"

case $DEPVER in
    5.8.8)
        DEPENDS_IPS="$DEPENDS_IPS omniti/runtime/perl omniti/incorporation/perl-588-incorporation"
        ;;
    5.14.2)
        DEPENDS_IPS="$DEPENDS_IPS omniti/runtime/perl omniti/incorporation/perl-5142-incorporation"
        ;;
    "")
        logerr "You must specify a version with -d DEPVER. Valid versions: $VERLIST"
        ;;
esac

PERL64="/opt/OMNIperl/bin/$ISAPART64/perl"

BUILDARCH=64
NO_PARALLEL_MAKE=1

CONFIGURE_OPTS="--enable-perl-glue"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64
    --with-perl=$PERL64
    --with-apache2-apxs=/opt/apache22/bin/$ISAPART64/apxs"

build_cpan_dependency() {
    local DOWNLOAD_PATH=$1
    local PACKAGE=$2
    local OLDBUILDDIR=$BUILDDIR
    local BUILDHELPDIR=$BUILDDIR/buildhelp.CPAN
    local BUILDDIR=$PACKAGE
    logmsg "Building dependency $PACKAGE"
    logcmd mkdir -p $TMPDIR/$BUILDHELPDIR ||
        logerr "Failed to create build dir for CPAN dependency"
    download_source $DOWNLOAD_PATH $PACKAGE "" $TMPDIR/$BUILDHELPDIR
    pushd $TMPDIR/$BUILDHELPDIR/$BUILDDIR > /dev/null
    logmsg "--- Makefile.PL (configure) 64-bit"
    logcmd $PERL64 Makefile.PL PREFIX=$TMPDIR/$BUILDHELPDIR ||
        logerr "Failed to run Makefile.PL"
    make_prog
    make_param install
    popd > /dev/null
    # Set perl5lib so future commands will use this lib
    export \
        PERL5LIB=$TMPDIR/$BUILDHELPDIR/lib:$TMPDIR/$BUILDHELPDIR/lib/site_perl
}

install_cpan_depends() {
    build_cpan_dependency CPAN/authors/id/J/JP/JPEACOCK version-0.99
    build_cpan_dependency CPAN/authors/id/D/DC/DCONWAY Parse-RecDescent-v1.95.1
    build_cpan_dependency CPAN/authors/id/G/GR/GRICHTER ExtUtils-XSBuilder-0.28
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
install_cpan_depends
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
