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
# Copyright 2016 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=ply
VER=3.9
PKG=library/python-2/ply
SUMMARY="ply - Python lex and yacc"
DESC="$SUMMARY"

DEPENDS_IPS="runtime/python-26"

make_license() {
    # Sigh. People. put the license in a standalong file!
    awk '/Copyright/,/DAMAGE.$/{print}' $TMPDIR/$BUILDDIR/README.md > \
        $TMPDIR/$BUILDDIR/LICENSE
}
init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_license
make_package
clean_up
