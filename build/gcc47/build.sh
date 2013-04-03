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

PROG=gcc
VER=4.7.2
VERHUMAN=$VER
PKG=developer/gcc47
SUMMARY="gcc ${VER}"
DESC="$SUMMARY"

export LD_LIBRARY_PATH=/opt/gcc-${VER}/lib
PATH=/usr/perl5/5.16.1/bin:$PATH
export PATH

DEPENDS_IPS="developer/gcc47/libgmp-gcc47 developer/gcc47/libmpfr-gcc47 developer/gcc47/libmpc-gcc47
	     developer/gnu-binutils developer/library/lint developer/linker system/library/gcc-4-runtime"
NO_PARALLEL_MAKE=1

# This stuff is in its own domain
PKGPREFIX=""

[[ "$BUILDARCH" == "both" ]] && BUILDARCH=32
PREFIX=/opt/gcc-${VER}
reset_configure_opts
CC=gcc

LD_FOR_TARGET=/bin/ld
export LD_FOR_TARGET
LD_FOR_HOST=/bin/ld
export LD_FOR_HOST
LD=/bin/ld
export LD

CONFIGURE_OPTS_32="--prefix=/opt/gcc-${VER}"
CONFIGURE_OPTS="--host i386-pc-solaris2.11 --build i386-pc-solaris2.11 --target i386-pc-solaris2.11 \
	--with-boot-ldflags=-R/opt/gcc-${VER}/lib \
	--with-gmp=/opt/gcc-${VER} --with-mpfr=/opt/gcc-${VER} --with-mpc=/opt/gcc-${VER} \
	--enable-languages=c,c++,fortran,lto --enable-ld=no \
	--with-as=/usr/bin/gas --with-gnu-as --with-build-time-tools=/usr/gnu/i386-pc-solaris2.11/bin"
LDFLAGS32="-R/opt/gcc-${VER}/lib"
export LD_OPTIONS="-zignore -zcombreloc -i"

save_function configure32 configure32_orig
configure32() {
    logmsg "This is evil... sudo chmod'ing gnu ld"
    logcmd sudo chmod 644 /usr/gnu/i386-pc-solaris2.11/bin/ld
    configure32_orig
    logmsg "This is evil... chmodding gnu ld back"
    logcmd sudo chmod 755 /usr/gnu/i386-pc-solaris2.11/bin/ld
}

init
download_source $PROG/releases/$PROG-$VER $PROG $VER
patch_source
prep_build
build
make_package gcc.mog
clean_up
