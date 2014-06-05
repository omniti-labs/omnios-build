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

PROG=graphviz
VER=2.38.0
VERHUMAN=$VER
PKG=omniti/image/graphviz
SUMMARY="$PROG - Graph Visualization Software"
DESC="Graphviz is open source graph visualization software. Graph visualization is a way of representing structural information as diagrams of abstract graphs and networks."

BUILD_DEPENDS_IPS="developer/lexer/flex omniti/developer/swig omniti/library/libjpeg omniti/library/libpng"

BUILDARCH=64
CONFIGURE_OPTS="--enable-perl=no --enable-python=no --enable-tcl=no"

init
# Retarded, but otherwise configure explodes
logmsg "Removing source directory"
logcmd rm -rf $TMPDIR/$BUILDDIR
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
