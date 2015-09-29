#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

if [ -z "$DEPVER" ]; then
    DEPVER=5.16.1
fi

AUTHORID=TODDR
PROG=XML-Parser
MODNAME=XML::Parser
VER=2.44
VERHUMAN=$VER
PKG=library/perl-5/xml-parser
SUMMARY="XML::Parser perl module ($VER)"
DESC="$SUMMARY"

PREFIX=/usr/perl5
reset_configure_opts

NO_PARALLEL_MAKE=1

BUILD_DEPENDS_IPS="runtime/perl runtime/perl-64"
DEPENDS_IPS="library/expat runtime/perl runtime/perl-64"

init
download_source CPAN/authors/id/${AUTHORID:0:1}/${AUTHORID:0:2}/${AUTHORID} $PROG $VER
patch_source
prep_build
buildperl
vendorizeperl
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
