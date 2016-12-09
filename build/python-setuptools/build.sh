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

# Pardon the copy/paste, but we have to do this twice (2.6 & 2.7) for now.
# And the only way buildctl detects packages is by grepping for PKG assignment.

OLDPV=$PYTHONVER

set_python_version 2.6
XFORM_ARGS="-D PYTHONVER=$PYTHONVER"
RUN_DEPENDS_IPS="runtime/python-26"
PKG=library/python-2/setuptools-26
init
prep_build
mkdir -p $DESTDIR/usr/lib/python2.6/vendor-packages
PYTHONPATH=$DESTDIR/usr/lib/python2.6/vendor-packages \
    python2.6 ez_setup.py --always-copy \
        --install-dir $DESTDIR/usr/lib/python2.6/vendor-packages/ \
        setuptools
make_package
clean_up

set_python_version 2.7
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

set_python_version $OLDPV
