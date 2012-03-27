#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

http://search.cpan.org/CPAN/authors/id/T/TO/TODDR/XML-Parser-2.41.tar.gz
if [ -z "$DEPVER" ]; then
    DEPVER=5.14.2
fi

AUTHORID=TODDR
PROG=XML-Parser
MODNAME=XML::Parser
VER=2.41
VERHUMAN=$VER
PKG=library/perl-5/$(echo $PROG | tr '[A-Z]' '[a-z]')
SUMMARY="XML::Parser perl module ($VER)"
DESC="$SUMMARY"

PREFIX=/usr/perl5
reset_configure_opts

NO_PARALLEL_MAKE=1

# Only 5.14.2 and later will get individual module builds
PERLVERLIST="5.14.2"

# Add any additional deps here; OMNIperl added below
BUILD_DEPENDS_IPS="perl-5142 perl-5142-64"
DEPENDS_IPS="library/libxml2@2.7.8"

# We require a Perl version to use for this build and there is no default
case $DEPVER in
    5.14.2)
        DEPENDS_IPS="$DEPENDS_IPS runtime/perl-5142"
        ;;
    "")
        logerr "You must specify a version with -d DEPVER. Valid versions: $PERLVERLIST"
        ;;
esac

init
test_if_core
download_source CPAN/authors/id/${AUTHORID:0:1}/${AUTHORID:0:2}/${AUTHORID} $PROG $VER
patch_source
prep_build
buildperl
vendorizeperl
cp $SRCDIR/Artistic $DESTDIR/license
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
