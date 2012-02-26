#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=sudo      # App name
VER=1.8.4p1        # App version
VERHUMAN=1.8.4p1   # Human-readable version
PVER=0.1          # Package Version (numeric only)
PKG=security/sudo # Package name (without prefix)
SUMMARY="$PROG - authority delegation tool"
DESC="$SUMMARY" # Longer description

CONFIGURE_OPTS_32="$CONFIGURE_OPTS_32 --bindir=/usr/bin --sbindir=/usr/sbin --libexecdir=/usr/lib/sudo"
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_64 --libexecdir=/usr/lib/sudo/amd64"
CONFIGURE_OPTS="
    --with-ldap
    --with-project
    --with-timedir=/var/run/sudo
    --with-pam --with-pam-login
    --with-tty-tickets
    --without-insults
    --without-lecture
    --with-ignore-dot
    --with-bsm-audit
"

make_install64() {
    # If this file exists, install will attempt to validate it
    # which will fail becuase we aren't running as root
    logcmd rm -f $DESTDIR/etc/sudoers
    make_install
    # Now cleanup the bits we didn't want (amd64 bins/includes)
    logcmd rm -rf $DESTDIR/usr/bin/amd64
    logcmd rm -rf $DESTDIR/usr/sbin/amd64
    logcmd rm -rf $DESTDIR/usr/include/amd64
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
VER=1.8.4.1
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
