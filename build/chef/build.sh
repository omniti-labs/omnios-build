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

# TODO - most of the guts of this build script have been copied into ../../lib/gem-functions.sh .  TODO - alter this script to use them, like vagrant

PROG=chef       # App name
VER=0.10.8      # App version
VERHUMAN=$VER   # Human-readable version
PKG=omniti/system/management/chef       # Package name (without prefix)
SUMMARY="$PROG" # A short summary of what the app is, starting with its name
DESC="$SUMMARY ($VER)" # Longer description

BUILDARCH=32
DEPENDS_IPS="omniti/runtime/ruby-19"
BUILD_DEPENDS_IPS="gnu-coreutils gnu-findutils omniti/runtime/ruby-19"

# we Fetch all of these direclty from rubygens.org. you can chnage that in the files/gemrc.
GEM_DEPENDS="
mixlib-config-1.1.2
mixlib-cli-1.2.2
mixlib-log-1.3.0
mixlib-authentication-1.1.4
systemu-2.5.0
yajl-ruby-1.1.0
ipaddress-0.8.0
ohai-0.6.12
mime-types-1.18
rest-client-1.6.7
bunny-0.7.9
polyglot-0.3.3
treetop-1.4.10
net-ssh-2.1.4
net-ssh-gateway-1.1.0
net-ssh-multi-1.1
erubis-2.7.0
moneta-0.6.0
highline-1.6.11
uuidtools-2.1.2
ffi-1.0.11"

export MAKE=gmake
GEM_BIN=/opt/omni/bin/gem
RUBY_VER=1.9

build32(){
    logmsg "Building"
    pushd $TMPDIR/$BUILDDIR > /dev/null
    GEM_HOME=${DESTDIR}${PREFIX}/lib/ruby/gems/${RUBY_VER}
    export GEM_HOME
    RUBYLIB=${DESTDIR}${PREFIX}/lib/ruby:${DESTDIR}${PREFIX}/lib/site_ruby/${RUBY_VER}
    export RUBYLIB
    for i in $GEM_DEPENDS; do
      GEM=${i%-[0-9.]*}
      GVER=${i##[^0-9.]*-}
      logmsg "--- gem install $GEM-$GVER"
      logcmd $GEM_BIN --config-file $SRCDIR/files/gemrc install \
        -r --no-rdoc --no-ri -i ${GEM_HOME} -v $GVER $GEM || \
        logerr "Failed to install $GEM-$GVER"
    done
    logmsg "--- gem install $PROG-$VER"
    logcmd $GEM_BIN --config-file $SRCDIR/files/gemrc install \
         -r --no-rdoc --no-ri -i ${GEM_HOME} -v $VER $PROG || \
        logerr "Failed to gem install $PROG-$VER"
    logmsg "--- Fixing include paths on binaries"
    for i in $GEM_HOME/bin/*; do
      sed -e "/require 'rubygems'/ a\\
Gem.use_paths(Gem.dir, [\"/opt/omni/lib/ruby/gems/${RUBY_VER}\"])\\
Gem.refresh\\
" $i >$i.tmp
      mv $i.tmp $i
      chmod +x $i
    done
}

patch_ohai() {
    logmsg "patching ohai"
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd patch -p1 -t -N ${DESTDIR}${PREFIX}/lib/ruby/gems/1.9/gems/ohai-0.6.12/lib/ohai/plugins/solaris2/platform.rb < $SRCDIR/$PATCHDIR/platform.patch || logerr "failed to patch ohai"
    popd 
}

make_bin_symlinks() {
    logmsg "Linking commands into $PREFIX/bin"
    logcmd mkdir -p ${DESTDIR}${PREFIX}/bin
    pushd ${DESTDIR}${PREFIX}/bin > /dev/null
    for c in $(gfind ${DESTDIR}${PREFIX}/lib/ruby/gems/1.9/bin/ -type f -printf "%f "); do
        logcmd ln -s $PREFIX/lib/ruby/gems/1.9/bin/$c $c
    done
    popd > /dev/null
}
    

init
mkdir -p $TMPDIR/$PROG-$VER
prep_build
build
patch_ohai
make_isa_stub
make_bin_symlinks
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
