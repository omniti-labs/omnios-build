#!/usr/bin/bash

# this will build
#
#   * make
#   * sccs
#   * assorted bin-only bits: (from sub root)
#     * as
#     * libtdf
#     * libxprof
#     * libxprof_audit

# Load support functions
. ../../lib/functions.sh

PROG=make   # App name
VER=0.5.11       # App version
PVER=0.2006.12.19  # Package Version
PKG=developer/build/make ##IGNORE##
SUMMARY="Omni-OS Bundled Development Tools"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="solstudio12.2 compatibility/ucb"
DEPENDS_IPS="system/library SUNWcs system/library/math"

CONFIGURE_OPTS=""
PKGE=$(url_encode $PKG)
DESTDIR=$DTMPDIR/make_pkg

prebuild_clean() {
    logmsg "Cleaning destdir: $DESTDIR"
    logcmd rm -rf $DESTDIR
}

build() {
    logmsg "Building and installing ($1)"
    pushd $TMPDIR/$1/usr/src > /dev/null || logerr "can't enter build harness"
    logcmd env STUDIOBIN=/opt/solstudio12.2/bin DESTDIR=$DESTDIR ./build ||
        logerr "make/install ($1) failed"
    popd > /dev/null
}

place_bins() {
    logmsg "Moving closed bins into place"
    (cd $SRCDIR/root && tar cf - .) | (cd $DESTDIR && tar xf -) ||
        logerr "Failed to copy closed bins"
}
move_and_links() {
    logmsg "Shifting binaries and setting up links"
    logcmd mv $DESTDIR/usr/ccs/bin/help $DESTDIR/usr/bin/sccshelp
    pushd $DESTDIR/usr/ccs/bin > /dev/null || logerr "Cannot chdir"
    for cmd in *
    do
        logcmd mv $cmd $DESTDIR/usr/bin/ || logerr "Cannot relocate /usr/ccs/bin/$cmd"
        logcmd ln -s ../../$cmd $cmd
    done
    logcmd ln -s ../../sccshelp $DESTDIR/usr/ccs/bin/sccshelp
    logcmd ln -s ../../sccshelp $DESTDIR/usr/ccs/bin/help
    popd > /dev/null
}

init

prebuild_clean

BUILDDIR=devpro-make-20061219
download_source devpro devpro-make src-20061219
build devpro-make-20061219

BUILDDIR=devpro-sccs-20061219
download_source devpro devpro-sccs src-20061219
build devpro-sccs-20061219

place_bins
move_and_links

make_package
clean_up
