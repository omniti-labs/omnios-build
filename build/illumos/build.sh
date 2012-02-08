#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=omni-os    # App name
VER=151001    # App version
PVER=1          # Package Version (numeric only)
PKG=$PROG       # Package name (without prefix)
SUMMARY="$PROG -- Open Maryland Not Indiana" # A short summary of what the app is, starting with its name
DESC="$SUMMARY -- OI 151 plus Illumos and some special sauce." # Longer description

#all of the ips depends should be available from an omni repo with the expection of sunstudio12u1, that comes from http://pkg.openindiana.org/legacy

BUILD_DEPENDS_IPS="data/docbook developer/astdev developer/build/make developer/build/onbld developer/gcc-3 developer/java/jdk developer/lexer/flex developer/object-file developer/parser/bison developer/versioning/mercurial library/glib2 library/libxml2 library/libxslt library/nspr/header-nspr library/perl-5/xml-parser library/security/trousers print/cups print/filter/ghostscript runtime/perl-510 runtime/perl-510/extra system/library/math/header-math system/library/install system/library/dbus system/library/libdbus system/library/libdbus-glib system/library/mozilla-nss/header-nss system/management/product-registry system/management/snmp/net-snmp text/gnu-gettext library/python-2/python-extra-24 web/server/apache-13 sunstudio12.1-12.1"

GIT=/opt/omni/bin/git

USE_SYSTEM_SSL_HEADERS="TRUE"

#PKGSERVER="http://10.80.117.210:10001"
PKGSERVER="http://pkg.omniti.com:10005" # nightly repo
PKGPREFIX=""
PREFIX=""
TMPDIR=/var/tmp
BUILDDIR=$PROG-$VER
CODEMGR_WS=$TMPDIR/$BUILDDIR/illumos-omni-os

#Since these variables are used in a sed statment make sure to escape properly
ILLUMOS_NO="NIGHTLY\_OPTIONS=\'\-nCmpr\'"
ILLUMOS_CODEMGR_WS="CODEMGR\_WS=\/var\/tmp\/$BUILDDIR\/illumos\-omni\-os"
#ILLUMOS_CLONE_WS="CLONE\_WS=\'ssh:\/\/anonhg@hg.illumos.org\/illumos\-gate\'"
ILLUMOS_CLONE_WS="CLONE\_WS=\'src@src.omniti.com:~omni-os\/core\/illumos\-omni\-os\'"

ILLUMOS_PKG_REDIST="PKGPUBLISHER\_REDIST=\'os\.omniti\.com\'"

#Now defined in clone_source
#ILLUMOS_VERSION="VERSION=\'omni\-os\'"

#these variables are appended to the end of the script so no need to escape
ILLUMOS_GNUC="export __GNUC='';"
ILLUMOS_NO_SHADOW="export CW_NO_SHADOW=1;"
ILLUMOS_BUILDNUM="ONNV_BUILDNUM=$VER; export ONNV_BUILDNUM;"

sunstudio_location() {
    logmsg "Ensuring that Sun Studio is where Illumos thinks it is..."
    logcmd mkdir -p /opt/SUNWspro
    logcmd ln -s /opt/sunstudio12.1/ /opt/SUNWspro 
}

#In order for the clone to work while running as root, you must have ssh'ed into the box with agent forwarding turned on.  Also the sudo'er file must either have the default, group, or user set to allow SSL_AUTH_SOCK.

clone_source(){
    logmsg "Creating tmp dir..."
    logcmd mkdir $TMPDIR/$BUILDDIR
    pushd $TMPDIR/$BUILDDIR > /dev/null 
    logmsg "Cloning OMNI Illumos Source..."
    logcmd  $GIT clone -b omni src@src.omniti.com:~omni-os/core/illumos-omni-os 
    logcmd  cd illumos-omni-os 
    ILLUMOS_VERSION="VERSION=\'omni\-os\-`$GIT log --pretty=format:'%h' -n 1`'" 
    echo $ILLUMOS_VERSION
    popd > /dev/null 
}

build_tools(){
    pushd $CODEMGR_WS > /dev/null
    logmsg "Building extra tools needed for illumos pkgs..."
    logcmd ln -s usr/src/tools/scripts/bldenv.sh .
    logcmd ksh93 bldenv.sh -d illumos.sh -c "cd usr/src && dmake setup" 
    popd > /dev/null
}

modify_build_script() {
    pushd $CODEMGR_WS > /dev/null
    logmsg "Changing illumos.sh variables to what we want them to be..."
    logcmd cp usr/src/tools/env/illumos.sh .    
    logcmd sed -i .tmp -e 's/^.*export NIGHTLY_OPTIONS.*/export '$ILLUMOS_NO'/g;s/^.*export CODEMGR_WS=.*/export '$ILLUMOS_CODEMGR_WS'/g;s/^.*export CLONE_WS=.*/export '$ILLUMOS_CLONE_WS'/g;s/^.*export PKGPUBLISHER_REDIST=.*/export '$ILLUMOS_PKG_REDIST'/g;s/^.*export VERSION=.*/export '$ILLUMOS_VERSION'/g;/^.*GNUC=.*/d;/^.*CW_NO_SHADOW=.*/d;/^.*ONNV_BUILDNUM=.*/d' illumos.sh 
    logcmd `echo $ILLUMOS_GNUC >> illumos.sh` 
    logcmd `echo $ILLUMOS_NO_SHADOW >> illumos.sh`
    logcmd `echo $ILLUMOS_BUILDNUM >> illumos.sh`
    popd > /dev/null

}

closed_bins() {
    pushd $CODEMGR_WS > /dev/null
    logmsg "Getting Closed Source Bins..."
#    logcmd wget -c http://mirrors.omniti.com/cdrom/Sun/on-closed-bins.i386.tar.bz2 http://mirrors.omniti.com/cdrom/Sun/on-closed-bins-nd.i386.tar.bz2
    logcmd wget -c http://mirrors.omniti.com/cdrom/Sun/on-closed-bins.i386.tar.bz2 http://mirrors.omniti.com/cdrom/Sun/on-closed-bins-nd.i386.tar.bz2
    logcmd tar xvpf on-closed-bins.i386.tar.bz2
    logcmd tar xvpf on-closed-bins-nd.i386.tar.bz2
    popd > /dev/null 
}

build_pkgs() {
    pushd $CODEMGR_WS > /dev/null
    logmsg "Building illumos pkgs..."
    logcmd cp usr/src/tools/scripts/nightly.sh .
    logcmd chmod +x nightly.sh
    logcmd ./nightly.sh illumos.sh
    popd > /dev/null
}

push_pkgs() {
    pushd $CODEMGR_WS > /dev/null
    logmsg "Pushing illumos pkgs to $PKGSERVER..."
    logcmd pkgrecv -s packages/i386/nightly-nd/repo.redist/ -d $PKGSERVER 'pkg:/*'
    popd > /dev/null
}

init
prep_build
sunstudio_location
clone_source
modify_build_script
closed_bins
build_tools
build_pkgs
push_pkgs
clean_up

