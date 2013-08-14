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

PROG=docutils
VER=0.11
VERHUMAN=$VER
PKG=omniti/library/python-2/docutils
SUMMARY="Python text processing system"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="omniti/runtime/python-26"
DEPENDS_IPS="omniti/runtime/python-26"

BUILDARCH=64
PYTHON=/opt/python26/bin/python
LDFLAGS64="-L$PYTHONLIB -R$PYTHONLIB -L/opt/omni/lib/$ISAPART64 -R/opt/omni/lib/$ISAPART64"
PATH=/opt/omni/bin:/opt/python26/bin:$PATH

link_bins() {
    logmsg "--- Symlinking binaries"
    pushd ${DESTDIR}/opt/python26/bin
    for BIN in `ls *.py` ; do
        NEWBIN=$(basename $BIN | cut -d. -f1)
        logcmd ln -sf $BIN $NEWBIN
    done
    popd
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
link_bins
make_package
clean_up
