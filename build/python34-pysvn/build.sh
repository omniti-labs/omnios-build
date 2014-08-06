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

PROG=pysvn
VER=1.7.9
VERHUMAN=$VER
PKG=omniti/library/python-34/pysvn
SUMMARY="SVN adapter for Python"
DESC=$SUMMARY

# omniti-ms python is 64-bit only
BUILDARCH=64
PYTHON=/opt/python34/bin/python3.4
PYTHONVER=python3.4
PYTHONLIB=/opt/python34/lib

CONFIGURE_OPTS="--svn-inc-dir=/opt/omni/include/subversion-1 
--svn-lib-dir=/opt/omni/lib 
--svn-bin-dir=/opt/omni/bin 
--apr-inc-dir=/opt/omni/include 
--apu-inc-dir=/opt/omni/include 
--apr-lib-dir=/opt/omni/lib 
--pycxx-dir=../Import/pycxx-6.2.5 
--pycxx-src-dir=../Import/pycxx-6.2.5/Src"


pysvn_build() {
    logmsg "Configuring pysvn"
    pushd $TMPDIR/$BUILDDIR/Source > /dev/null
    logcmd make clean
    logcmd $PYTHON setup.py configure $CONFIGURE_OPTS	
    logmsg "Making pysvn"
    logcmd make
    logmsg "Installing pysvn into $PYSVNDIR"
    logcmd mkdir -p $DESTDIR$PYTHONLIB/$PYTHONVER/pysvn || \
        logerr "--- Unable to create pysvn directory"
    logcmd rsync -a pysvn/ $DESTDIR$PYTHONLIB/$PYTHONVER/pysvn/ || \
        logerr "--- Unable to copy files to pysvn directory"
    popd > /dev/null
} 

DEPENDS_IPS="omniti/runtime/python-34 omniti/library/neon omniti/developer/versioning/subversion"
BUILD_DEPENDS_IPS=$DEPENDS_IPS

init
download_source $PROG $PROG $VER
prep_build
patch_source
pysvn_build
make_package
clean_up
