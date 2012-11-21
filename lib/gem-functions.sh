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

# Adapted from ms branch build/chef/build.sh 

BUILDARCH=32
DEPENDS_IPS="omniti/runtime/ruby-19"
BUILD_DEPENDS_IPS="gnu-coreutils"

GEM_BIN=/opt/omni/bin/gem
RUBY_VER=1.9

# Place your ordered list of dependencies in this var

GEM_DEPENDS=""

# Optionally, provide a gemrc in your build dir/files/gemrc.

build32(){
    logmsg "Building"

    if [[ -e $SRCDIR/files/gemrc ]]; then
        GEMRC=$SRCDIR/files/gemrc
    else
        GEMRC=$MYDIR/gemrc
    fi

    pushd $TMPDIR/$BUILDDIR > /dev/null
    GEM_HOME=${DESTDIR}${PREFIX}/lib/ruby/gems/${RUBY_VER}
    export GEM_HOME
    RUBYLIB=${DESTDIR}${PREFIX}/lib/ruby:${DESTDIR}${PREFIX}/lib/site_ruby/${RUBY_VER}
    export RUBYLIB
    for i in $GEM_DEPENDS; do
      GEM=${i%-[0-9.]*}
      GVER=${i##[^0-9.]*-}
      logmsg "--- gem install $GEM-$GVER"
      logcmd $GEM_BIN --config-file $GEMRC install \
        -r --no-rdoc --no-ri -i ${GEM_HOME} -v $GVER $GEM || \
        logerr "Failed to install $GEM-$GVER"
    done
    logmsg "--- gem install $PROG-$VER"
    logcmd $GEM_BIN --config-file $GEMRC install \
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

download_source() {
    # Just make the temp build dir
    logcmd mkdir -p $TMPDIR/$PROG-$VER
}
