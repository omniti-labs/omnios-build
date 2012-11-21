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

PKGPUBLISHER=root.omnios.omniti.com
PKGSRVR=http://localhost:888/

PROG=vagrant      # App name
VER=1.0.5            # App version
VERHUMAN=$VER   # Human-readable version
#PVER=          # Branch (set in config.sh, override here if needed)
PKG=omniti/developer/vagrant    # Package name (e.g. library/foo)
SUMMARY="Vagrant, a tool for creating repeatable, lightweight development environments.  The glue between VirtualBox and Chef."      # One-liner, must be filled in
DESC="$SUMMARY"         # Longer description, must be filled in

BUILD_DEPENDS_IPS="omniti/runtime/ruby-19 omniti/library/ruby/bundler"
IPS_DEPENDS="
omniti/system/virtualbox
omniti/runtime/ruby-19
omniti/library/ruby/bundler
omniti/system/management/chef
"

# It ships with the @#!$#$% kitchen sink
GEM_DEPENDS="
"

init
download_source
patch_source
prep_build
build

# Now make a wrapper to set the gem path 
# If mitchellh had included 'require "rubygems"' in the bin script, the 
# gem_functions build32 woudl have caught it
logcmd mkdir -p $DESTDIR/opt/omni/bin
WRAPPER=$DESTDIR/opt/omni/bin/vagrant
echo '#!/bin/bash' > $WRAPPER
echo 'export GEM_PATH=$GEM_PATH:/opt/omni/lib/ruby/gems/'$RUBY_VER >> $WRAPPER
echo "exec /opt/omni/lib/ruby/gems/$RUBY_VER/gems/vagrant-$VER/bin/vagrant \$@" >> $WRAPPER
logcmd chmod 0755 $WRAPPER

make_isa_stub
make_package $SRCDIR/vagrant.mog
clean_up


# Vim hints
# vim:ts=4:sw=4:et:
