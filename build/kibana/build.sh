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
. ../../lib/gem-functions.sh

# PKGPUBLISHER=root.omnios.omniti.com
# PKGSRVR=http://localhost:888/

PROG=Kibana     # App name
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=omniti/system/kibana            # Package name (e.g. library/foo)
SUMMARY="Kibana logstash frontend"      # One-liner, must be filled in
DESC="$SUMMARY"         # Longer description, must be filled in
BUILD_DEPENDS_IPS="text/gnu-sed"
DEPENDS_IPS="omniti/runtime/ruby-19 omniti/library/ruby/bundler omniti/system/elasticsearch"

# no nonstandard deps

build() {
    export MAKE=gmake
    export GEM_PATH=/opt/omni/lib/ruby/gems/1.9:/opt/omni/lib/ruby/gems/1.9.1:${DESTDIR}/opt/kibana/bundle
    export GEM_HOME=/opt/kibana/bundle
    logcmd mkdir -p $DESTDIR/opt/kibana/bundle || logerr "mkdir failed"
    logcmd cp -r $TMPDIR/$BUILDDIR/. $DESTDIR/opt/kibana/. || logerr "cp -r failed"
    pushd ${DESTDIR}/opt/kibana || logerr "pushd failed"
    logcmd rm -rf ${DESTDIR}/opt/kibana/.git || logerr "dropping .git failed"
    logcmd /opt/omni/lib/ruby/gems/1.9/gems/bundler-1.2.2/bin/bundle install --path ${DESTDIR}/opt/kibana/bundle || \
        logerr "bundling failed"
    logcmd cp KibanaConfig.rb KibanaConfig.rb.factory || logerr "cp failed"
    logcmd gsed -e '/^ *Kibana[HP]/d; s/# \(Kibana[HP]\)/\1/g; '"s/'localhost'/'0.0.0.0'/g;" -i KibanaConfig.rb || \
        logerr "fixup config failed"
    logcmd mkdir -p ${DESTDIR}/lib/svc/manifest/system/ || logerr "faied to mkdir SMF path"
    logcmd cp $SRCDIR/files/kibana.xml ${DESTDIR}/lib/svc/manifest/system/ || logerr "failed to install SMF"
    popd
}

init
prep_build
download_git https://github.com/rashidkpc/Kibana.git kibana-ruby
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
