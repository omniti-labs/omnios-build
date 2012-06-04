#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=nad
VER=git  # The real version is set in download_git()
PKG=omniti/monitoring/nad
SUMMARY="Node Agent"
DESC="nad is a monitoring agent written in Node.js that runs your monitoring scripts, executables, etc. and outputs JSON-formatted data."

DEPENDS_IPS="omniti/runtime/nodejs"

GIT=/usr/bin/git
PATH=$PATH:/opt/omni/bin

BUILDARCH=64

download_git() {
    REPOS=$1
    BUILDDIR=$2
    REV=$3
    # Create TMPDIR if it doesn't exist
    if [[ ! -d $TMPDIR ]]; then
        logmsg "Specified temp directory $TMPDIR does not exist.  Creating it now."
        logcmd mkdir -p $TMPDIR
    fi
    pushd $TMPDIR > /dev/null
    logmsg "Checking for source directory"
    if [ -d $BUILDDIR ]; then
        logmsg "Removing source directory"
        rm -rf $BUILDDIR
    fi
    if [ ! -d $BUILDDIR ]; then
        logmsg "Checking code out from $REPOS"
        logcmd $GIT clone $REPOS $BUILDDIR
    fi
    pushd $BUILDDIR > /dev/null
    $GIT pull
    if [ -n $REV ]; then $GIT checkout $REV; fi
    REV=`$GIT log -1  --format=format:%at`
    if [[ $VER == "git" ]]; then
        VER="0.1.$REV"
    fi
    REVDATE=`echo $REV | gawk '{ print strftime("%c %Z",$1) }'`
    popd > /dev/null
    popd > /dev/null
}

# Nothing to configure, it's just node scripts
configure64() {
    true
}

init
download_git git://github.com/omniti-labs/nad.git $PROG-$VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
