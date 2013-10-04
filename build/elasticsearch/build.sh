#!/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=elasticsearch
VER=0.90.5
RPMREV=3
PKG=omniti/system/elasticsearch
SUMMARY="ElasticSearch - Open Source, Distributed, RESTful, Search Engine"
DESC="$SUMMARY"
PREFIX=/opt
reset_configure_opts

BUILD_DEPENDS_IPS="developer/versioning/git"
DEPENDS_IPS="runtime/java"

# There is nothing to configure/build-- we just want to package the files
# That also means there's no sense in building 32/64-bit
BUILDARCH=64

build64() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Copying source files"
    logcmd mkdir -p ${DESTDIR}${PREFIX}/$PROG || \
        logerr "--- Unable to create destination directory"
    logcmd rsync -a . ${DESTDIR}${PREFIX}/$PROG/ || \
        logerr "--- Unable to copy files to destination directory"
    logcmd mkdir -p ${DESTDIR}${PREFIX}/${PROG}/var/{log,data,work} || \
        logerr "--- Unable to stub var dirs"
    logcmd cp $DESTDIR${PREFIX}/$PROG/config/logging.yml{,.factory} || \
        logerr "--- Failed to copy factory logging config"
    logcmd cp $DESTDIR${PREFIX}/$PROG/config/elasticsearch.yml{,.factory} || \
        logerr "--- Failed to copy factory ES config"
    logcmd cp $SRCDIR/files/elasticsearch.yml $DESTDIR${PREFIX}/$PROG/config/elasticsearch.yml || \
        logerr "--- Failed to place initial config"
    logcmd mkdir -p ${DESTDIR}/lib/svc/manifest/system
    logcmd cp $SRCDIR/files/elasticsearch.xml ${DESTDIR}/lib/svc/manifest/system/ || \
        logerr "failed to install SMF"
    popd > /dev/null
    if [[ "$OSTYPE" == "Linux" ]]; then
        logmsg "Installing init script"
        logcmd mkdir -p $DESTDIR/etc/init.d
        logcmd cp $SRCDIR/init-scripts/circonus-elasticsearch $DESTDIR/etc/init.d/ || \
            logerr "Failed to install init script"
    fi
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
