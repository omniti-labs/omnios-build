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

PROG=binutils
VER=2.25
VERHUMAN=$VER
PKG=developer/gnu-binutils
SUMMARY="$PROG -  a collection of binary tools"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="gcc44"
[[ "$BUILDARCH" == "both" ]] && BUILDARCH=32

CONFIGURE_OPTS="--enable-gold=yes --exec-prefix=/usr/gnu --program-prefix=g"

# Use old gcc4 standards level for this.
CFLAGS="$CFLAGS -std=gnu89"

make_prog() {
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    logmsg "--- make"
    logcmd $MAKE SHELL=/bin/bash $MAKE_JOBS || \
        logerr "--- Make failed"
}

make_sfw_links() {
    logmsg "Creating SFW symlinks"
    logcmd mkdir -p $DESTDIR/$PREFIX/sfw/bin
    pushd $DESTDIR/$PREFIX/sfw/bin > /dev/null
    for file in gaddr2line gar gas gc++filt gelfedit ggprof gld gnm \
                gobjcopy gobjdump granlib greadelf gsize gstrings gstrip
        do logcmd ln -s ../../bin/$file $file || \
            logerr "Failed to create link for $file"
        done
    popd > /dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_sfw_links
make_package
clean_up
