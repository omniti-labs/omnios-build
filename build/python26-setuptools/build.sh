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

PROG=setuptools
VER=1.1.6
VERHUMAN=$VER
PKG=omniti/library/python-2/setuptools
SUMMARY="Easily download, build, install, upgrade, and uninstall Python packages"
DESC="Setuptools is a fully-featured, actively-maintained, and stable library designed to facilitate packaging Python projects"

BUILD_DEPENDS_IPS="omniti/runtime/python-26"
DEPENDS_IPS="omniti/runtime/python-26"

# omniti-ms python is 64-bit only
BUILDARCH=64
PYTHON=/opt/python26/bin/python

remove_broken_file()
{
  echo "Removing files that break pkgmogrify"
  logcmd rm "${DESTDIR}/opt/python26/lib/python2.6/site-packages/setuptools/script template.py" || printf "FAILED\n\n"
  logcmd rm "${DESTDIR}/opt/python26/lib/python2.6/site-packages/setuptools/script template.pyc" || printf "FAILED\n\n"
  logcmd rm "${DESTDIR}/opt/python26/lib/python2.6/site-packages/setuptools/script template (dev).py" || printf "FAILED\n\n"
  logcmd rm "${DESTDIR}/opt/python26/lib/python2.6/site-packages/setuptools/script template (dev).pyc" || printf "FAILED\n\n"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
remove_broken_file
make_package
clean_up
