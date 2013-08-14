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

PROG=chef       # App name
VER=11.4.4      # App version
VERHUMAN=$VER   # Human-readable version
PKG=omniti/system/management/chef-11
SUMMARY="Chef"
DESC="$SUMMARY ($VER)" # Longer description

BUILDARCH=32
DEPENDS_IPS="omniti/runtime/ruby-19"
BUILD_DEPENDS_IPS="gnu-coreutils gnu-findutils omniti/runtime/ruby-19"

# Which gems do we need? (enforces a consistent build)
# To generate this list, install the version of chef you want in an rvm or
# other test environment, and look for the 'Successfully installed ' lines.
# These mention the dependencies and the order in which they were installed.
GEM_DEPENDS="
mixlib-config-1.1.2
mixlib-cli-1.3.0
mixlib-log-1.6.0
mixlib-authentication-1.3.0
mixlib-shellout-1.1.0
systemu-2.5.2
yajl-ruby-1.1.0
ipaddress-0.8.0
ohai-6.16.0
mime-types-1.23
rest-client-1.6.7
json-1.7.7
net-ssh-2.6.7
net-ssh-gateway-1.2.0
net-ssh-multi-1.1
highline-1.6.19
erubis-2.7.0
"

make_bin_symlinks() {
    logmsg "Linking commands into $PREFIX/bin"
    logcmd mkdir -p ${DESTDIR}${PREFIX}/bin
    pushd ${DESTDIR}${PREFIX}/bin > /dev/null
    for c in ${DESTDIR}${PREFIX}/lib/ruby/gems/1.9/bin/*; do
        logcmd ln -s ${c#$DESTDIR}
    done
    popd > /dev/null
}

init
download_source
patch_source
prep_build
build
make_isa_stub
make_bin_symlinks
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
