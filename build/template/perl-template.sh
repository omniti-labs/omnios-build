#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

AUTHORID=FOOBAR              # Module author's ID
PROG=Module-Name             # Name of source download
MODNAME=Module::Name         # Module name for testing
VER=1.0                      # Module version
VERHUMAN=$VER                # Human-readable version
PVER=$DEPVER                 # Perl version from -d
PKG=perl-$(echo $PROG | tr '[A-Z]' '[a-z]')  # Module name, lowercased
SUMMARY="$PROG" # Don't just leave this as-is, fill in something meaningful
DESC="$SUMMARY (OmniTI roll) (Perl $DEPVER)"

PREFIX=/opt/OMNIperl
reset_configure_opts

NO_PARALLEL_MAKE=1

# Only 5.14.2 and later will get individual module builds
PERLVERLIST="5.14.2"

# Add any additional deps here; OMNIperl added below
#DEPENDS_IPS=

# We require a Perl version to use for this build and there is no default
case $DEPVER in
    5.14.2)
        DEPENDS_IPS="$DEPENDS_IPS OMNIperl =OMNIperl@5.14.2"
        ;;
    "")
        logerr "You must specify a version with -d DEPVER. Valid versions: $PERLVERLIST"
        ;;
esac

# In case any modules install site binaries into /opt/omni
save_function make_isa_stub make_isa_stub_orig
make_isa_stub() {
    PREFIX=/opt/omni make_isa_stub_orig
}

init
test_if_core
download_source CPAN/authors/id/${AUTHORID:0:1}/${AUTHORID:0:2}/${AUTHORID} $PROG $VER
patch_source
prep_build
buildperl
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
