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

PROG=cabundle   # App name
VER=5.11        # App version
VERHUMAN=$VER   # Human-readable version
NSSVER=3.16.4   # Keep this in sync with the version of system/library/mozilla-nss
PKG=web/ca-bundle  # Package name (without prefix)
SUMMARY="$PROG - Bundle of SSL Root CA certificates"
DESC="SSL Root CA certificates extracted from mozilla-nss $NSSVER source, plus OmniTI CA cert."

BUILDARCH=32

build_pem() {
  logmsg "Extracting certdata.txt from nss-$NSSVER source"
  # Fetch and extract the NSS source to get certdata.txt
  BUILDDIR_ORIG=$BUILDDIR
  BUILDDIR=nss-$NSSVER
  download_source nss nss $NSSVER
  BUILDDIR=$BUILDDIR_ORIG
  logcmd mkdir -p $TMPDIR/$BUILDDIR
  pushd $TMPDIR/$BUILDDIR > /dev/null
  logcmd cp $TMPDIR/nss-$NSSVER/nss/lib/ckfw/builtins/certdata.txt . || \
    logerr "--- Failed to copy certdata.txt file"
  logcmd $SRCDIR/mk-ca-bundle.pl -n cacert.pem || \
    logerr "--- Failed to convert certdata.txt into PEM format"
  logcmd cp $TMPDIR/nss-$NSSVER/nss/COPYING license || \
    logerr "--- Failed to copy license file"
  popd > /dev/null
}

install_pem() {
  logmsg "Installing PEM file"
  logcmd mkdir -p $DESTDIR/etc/ssl/certs || \
    logerr "------ Failed to create ssl directory"
  logmsg "Placing PEM in package root"
  logcmd cp $TMPDIR/$BUILDDIR/cacert.pem $DESTDIR/etc/ssl || \
    logerr "--- Failed to copy file"
  logmsg "--- Creating symlink from /etc/ssl"
  pushd $DESTDIR/etc/ssl/certs > /dev/null
  CNT=`awk '/BEGIN/{n++} END{print n-2}' $DESTDIR/etc/ssl/cacert.pem`
  logcmd csplit -n3 -f cert $DESTDIR/etc/ssl/cacert.pem '/END CERT/1' "{$CNT}"
  # first one will be blank
  for cert in cert*
  do
    if [ -s $cert ]; then
      HASH=`openssl x509 -hash -noout -in $cert`.0
      openssl x509 -text -in $cert >> $HASH
    fi
    rm $cert
  done
  popd > /dev/null
}

# Install the OmniTI CA cert separately, to be used by pkg(1)
install_omniti_cacert() {
  logmsg "Installing OmniTI CA cert for pkg(1) use"
  local cert="$SRCDIR/files/OmniTI_CA.pem"
  local subj_hash=`openssl x509 -hash -noout -in $cert`.0
  logcmd mkdir -p $DESTDIR/etc/ssl/pkg
  logcmd cp -p $cert $DESTDIR/etc/ssl/pkg/ || \
    logerr "--- Failed to copy CA cert"
  pushd $DESTDIR/etc/ssl/pkg/ > /dev/null
  logcmd ln -s OmniTI_CA.pem $subj_hash || \
    logerr "--- Failed to create subject hash link"
  popd > /dev/null
}

init
prep_build
build_pem
install_pem
install_omniti_cacert
make_package
clean_up
