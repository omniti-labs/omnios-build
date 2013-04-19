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
# We need this for the Sun assembler
LANG=C
export LANG
SHELL=/usr/bin/bash
export SHELL

# Load support functions
. ../../lib/functions.sh

case $DEPVER in
    "")
	DEPVER=5.16.1
        logmsg "no version specified, using $DEPVER"
        ;;
esac

PROG=perl
VER=$DEPVER
NODOTVER=$(echo $DEPVER| sed -e's/\.//g;')
PKG=runtime/perl-$NODOTVER
SUMMARY="Perl $VER Programming Language"
DESC="$SUMMARY"
PREFIX=/usr/perl5/${VER}

BUILD_DEPENDS_IPS="text/gnu-sed"

if [[ $VER == "5.8.8" ]]; then
    PATCHDIR="patches-5.8.8"
fi

catalog() {
    pushd $DESTDIR > /dev/null
    find . | cut -c3- > $TMPDIR/$1
    popd > /dev/null
}
build_mogs() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    ./miniperl $SRCDIR/make_mog.pl $TMPDIR $DESTDIR
    cat $TMPDIR/nodocs.mog $TMPDIR/no64.mog > $TMPDIR/perl.mog
    cat $TMPDIR/no32.mog $TMPDIR/no64.mog > $TMPDIR/perl-docs.mog
    cat $TMPDIR/no32.mog $TMPDIR/nodocs.mog > $TMPDIR/perl-64.mog
    popd > /dev/null
}
links() {
    mkdir -p $DESTDIR/usr/bin
    for firstclass in perl perldoc cpan
    do
        ln -s ../perl5/${VER}/bin/$firstclass $DESTDIR/usr/bin/$firstclass
    done
    mkdir -p $DESTDIR/usr/perl5/bin
    ln -s ../${VER}/bin/perl $DESTDIR/usr/perl5/bin/perl
}

build32() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 32-bit"
    logmsg "--- make (dist)clean"
    logcmd make distclean || \
        logmsg "--- *** WARNING *** make (dist)clean Failed"
    logmsg "--- configure (32-bit)"
    logcmd $SHELL Configure -Dusethreads -Duseshrplib -Dusemultiplicity -Duselargefiles \
	-Dusedtrace -Duse64bitint -Dmyhostname="localhost" \
        -Dcc=gcc -Dld=/usr/ccs/bin/ld -Dccflags="-D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -D_TS_ERRNO" \
        -Doptimize="-O3" \
        -Dvendorprefix=${PREFIX} -Dprefix=${PREFIX} \
        -Dbin=${PREFIX}/bin/$ISAPART \
        -Dsitebin=${PREFIX}/bin/$ISAPART \
        -Dvendorbin=${PREFIX}/bin/$ISAPART \
        -Dscriptdir=${PREFIX}/bin \
        -Dsitescript=${PREFIX}/bin \
        -Dvendorscript=${PREFIX}/bin \
	-Dprivlib=${PREFIX}/lib \
	-Dsitelib=/usr/perl5/site_perl/${VER} \
	-Dvendorlib=/usr/perl5/vendor_perl/${VER} \
        -des || \
    logerr "--- Configure failed"
    gsed -i 's/-fstack-protector//g;' config.sh
    logmsg "--- make"
    logcmd gmake -j 8 || \
    logcmd gmake || \
        logerr "--- Make failed"
    #logmsg "--- make test"
    #logcmd gmake test || \
    #    logerr "--- Make test failed"
    logmsg "--- make install"
    logcmd gmake install DESTDIR=${DESTDIR} || \
        logerr "--- Make install failed"
    # We make the isastubs after 32bit so we can seem them in the catalog
    make_isa_stub

    catalog perl.32.bit || logerr "Failed to catalog 32bit install"
    popd > /dev/null
}

build64() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 64-bit"
    logmsg "--- make (dist)clean"
    logcmd make distclean || \
        logmsg "--- *** WARNING *** make (dist)clean Failed"
    logmsg "--- configure (64-bit)"
    logcmd $SHELL Configure -Dusethreads -Duseshrplib -Dusemultiplicity -Duselargefiles \
	-Dusedtrace -Duse64bitint -Dmyhostname="localhost" \
        -Dcc=gcc -Dld=/usr/ccs/bin/ld -Dccflags="-D_LARGEFILE64_SOURCE -m64 -D_TS_ERRNO" \
        -Dlddlflags="-G -64" \
        -Dldflags="" \
        -Doptimize="-O3" \
        -Dvendorprefix=${PREFIX} -Dprefix=${PREFIX} \
        -Dbin=${PREFIX}/bin/$ISAPART64 \
        -Dsitebin=${PREFIX}/bin/$ISAPART64 \
        -Dvendorbin=${PREFIX}/bin/$ISAPART64 \
        -Dscriptdir=${PREFIX}/bin \
        -Dsitescript=${PREFIX}/bin \
        -Dvendorscript=${PREFIX}/bin \
	-Dprivlib=${PREFIX}/lib \
        -Dsitelib=/usr/perl5/site_perl/${VER} \
        -Dvendorlib=/usr/perl5/vendor_perl/${VER} \
        -des || \
    logerr "--- Configure failed"
    gsed -i 's/-fstack-protector//g;' config.sh
    gsed -i -e '/^lddlflags/{s/-G -m64//;}' config.sh
    logmsg "--- make"
    logcmd gmake -j 8 || \
    logcmd gmake || \
        logerr "--- Make failed"
    #logmsg "--- make test"
    #logcmd gmake test || \
    #    logerr "--- Make test failed"
    logmsg "--- make install"
    logcmd gmake install DESTDIR=${DESTDIR} || \
        logerr "--- Make install failed"

    pushd $DESTDIR/$PREFIX/bin > /dev/null
    gsed -i 's:usr/perl5/5.16.1/bin/amd64:usr/perl5/5.16.1/bin:g' \
        `find . -type f | xargs file | grep script | cut -f1 -d:`
    popd > /dev/null
    popd > /dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
links
build
catalog perl.all.bit || logerr "Failed to catalog full install"
build_mogs

PKG=runtime/perl
SUMMARY="Perl $VER Programming Language"
DESC="$SUMMARY"
DEPENDS_IPS="system/library/g++-4-runtime system/library/math system/library"
make_package $TMPDIR/perl.mog

PKG=runtime/perl/manual
SUMMARY="Perl $VER Programming Language Docs"
DESC="$SUMMARY"
DEPENDS_IPS="=runtime/perl@${VER},5.11-${PVER} runtime/perl@${VER},5.11-${PVER}"
make_package $TMPDIR/perl-docs.mog

PKG=runtime/perl-64
SUMMARY="Perl $VER Programming Language (64-bit)"
DESC="$SUMMARY"
DEPENDS_IPS="=runtime/perl@${VER},5.11-${PVER} runtime/perl@${VER},5.11-${PVER}"
make_package $TMPDIR/perl-64.mog

clean_up
