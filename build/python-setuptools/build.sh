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

PROG=setuptools
VER=0.6.11
SUMMARY="setuptools - yet another python packaging requirement"
DESC="$SUMMARY"

# In the future when we upgrade python again, be sure to wrap the following
# around with set_python_version and reassign PKG and RUN_DEPENDS_IPS.
# The only way buildctl detects packages is by grepping for PKG assignment.
XFORM_ARGS="-D PYTHONVER=$PYTHONVER"
RUN_DEPENDS_IPS="runtime/python-27"
PKG=library/python-2/setuptools-27
init
prep_build
mkdir -p $DESTDIR/usr/lib/python2.7/vendor-packages
PYTHONPATH=$DESTDIR/usr/lib/python2.7/vendor-packages \
    python2.7 ez_setup.py --always-copy \
        --install-dir $DESTDIR/usr/lib/python2.7/vendor-packages/ \
        setuptools
make_package
clean_up
