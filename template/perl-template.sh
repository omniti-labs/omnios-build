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

AUTHORID=FOOBAR              # Module author's ID
PROG=Module-Name             # Name of source download
MODNAME=Module::Name         # Module name for testing
VER=1.0                      # Module version
VERHUMAN=$VER                # Human-readable version
#PVER=                       # Branch (set in config.sh, override here if needed)
PKG=perl-$(echo $PROG | tr '[A-Z]' '[a-z]')  # Module name, lowercased
SUMMARY=""                   # Change this
DESC=""                      # Change this

PREFIX=/usr/perl5
reset_configure_opts

NO_PARALLEL_MAKE=1

# Only 5.16.1 and later will get individual module builds
PERLVERLIST="5.16.1"

# Add any additional deps here; perl runtime added below
#BUILD_DEPENDS_IPS=
#RUN_DEPENDS_IPS=

# We require a Perl version to use for this build and there is no default
case $DEPVER in
    5.16.1)
        RUN_DEPENDS_IPS="$RUN_DEPENDS_IPS runtime/perl"
        ;;
    "")
        logerr "You must specify a version with -d DEPVER. Valid versions: $PERLVERLIST"
        ;;
esac

# Uncomment and set PREFIX if any modules install site binaries
#save_function make_isa_stub make_isa_stub_orig
#make_isa_stub() {
#    PREFIX=/usr make_isa_stub_orig
#}

init
test_if_core
download_source CPAN/authors/id/${AUTHORID:0:1}/${AUTHORID:0:2}/${AUTHORID} $PROG $VER
patch_source
prep_build
buildperl
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
