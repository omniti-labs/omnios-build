#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=curl       # App name
VER=7.24.0      # App version
PVER=1          # Package Version
PKG=web/curl    # Package name (without prefix)
SUMMARY="$PROG - command line tool for transferring data with URL syntax"
DESC="$SUMMARY"

DEPENDS_IPS="web/ca-bundle library/security/openssl@1.0.0 library/zlib"

CONFIGURE_OPTS="--enable-thread --with-ca-bundle=/etc/cacert.pem"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
logerr "Intentional fail-- check build"
make_package
clean_up
