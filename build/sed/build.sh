#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=sed       # App name
VER=4.2.1        # App version
PVER=0.151002           # Package Version
PKG=text/gnu-sed    # Package name (without prefix)
SUMMARY="gsed - GNU implementation of sed, the Unix stream editor"
DESC="$SUMMARY"

DEPENDS_IPS="SUNWcs"

BUILDARCH=32
CONFIGURE_OPTS_32="--prefix=$PREFIX
        --sysconfdir=/etc
        --includedir=$PREFIX/include
        --bindir=$PREFIX/bin
        --sbindir=$PREFIX/sbin
        --libdir=$PREFIX/lib
        --libexecdir=$PREFIX/libexec
	--program-prefix=g"

link_up_gnu_sfw() {
    logmsg "Making links in /usr/gnu and /usr/sfw"
    logcmd mkdir -p $DESTDIR/usr/gnu/bin
    logcmd mkdir -p $DESTDIR/usr/gnu/share/man/man1
    for cmd in sed
    do
        logcmd ln -s ../../bin/g$cmd $DESTDIR/usr/gnu/bin/$cmd
        logcmd ln -s ../../../../share/man/man1/g$cmd.1 $DESTDIR/usr/gnu/share/man/man1/$cmd.1
    done
}
init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
strip_install
link_up_gnu_sfw
fix_permissions
make_package
clean_up
