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

PROG=ec2-api-tools
VER=1.7.1.0
VERHUMAN=$VER
PKG=system/management/ec2-api-tools
SUMMARY="The API tools serve as the client interface to the Amazon EC2 web service."
DESC="Use these tools to register and launch instances, manipulate security groups, and more."

BUILD_DEPENDS_IPS="network/rsync"
DEPENDS_IPS="runtime/java"

# Remove the dependence on EC2_HOME from all the commands,
# since ec2-cmd takes care of it.
# Just have each command script exec ec2-cmd
exec_fix() {
    logmsg "Cleaning up command scripts"
    find ${TMPDIR}/${BUILDDIR}/bin -type f | grep -v 'cmd$' | xargs sed -i -e '/^__ZIP_PREFIX.*/d' -e '/^__RPM_PREFIX.*/d' -e 's#^"${EC2_HOME}"/bin/#exec #'
}

install_files() {
    logmsg "Setting up proto area and copying files"
    for d in bin lib/ec2-api-tools share/doc/ec2-api-tools; do
        logcmd mkdir -p ${DESTDIR}${PREFIX}/$d || \
            logerr "--- Failed to mkdir ${DESTDIR}${PREFIX}/$d"
    done
    pushd ${TMPDIR}/${BUILDDIR} > /dev/null
    logcmd /usr/bin/rsync -a --exclude='*.cmd' bin/ ${DESTDIR}${PREFIX}/bin/ || \
        logerr "--- Failed to copy files to ${DESTDIR}${PREFIX}/bin/"
    logcmd /usr/bin/rsync -a lib/ ${DESTDIR}${PREFIX}/lib/ec2-api-tools/ || \
        logerr "--- Failed to copy files to ${DESTDIR}${PREFIX}/lib/ec2-api-tools/"
    logcmd cp -p *.{txt,TXT} ${DESTDIR}${PREFIX}/share/doc/ec2-api-tools/ || \
        logerr "--- Failed to copy files to ${DESTDIR}${PREFIX}/share/doc/ec2-api-tools/"
    popd > /dev/null
}

init
download_source ec2 $PROG $VER
patch_source
prep_build
exec_fix
install_files
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
