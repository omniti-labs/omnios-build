#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=grep       # App name
VER=2.10         # App version
PVER=0.1           # Package Version
PKG=text/gnu-grep    # Package name (without prefix)
SUMMARY="ggrep - GNU grep utilities"
DESC="$SUMMARY $VER"

DEPENDS_IPS="SUNWcs library/pcre"

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
    logcmd mkdir -p $DESTDIR/usr/sfw/bin
    for cmd in grep egrep fgrep
    do
        logcmd ln -s ../../bin/g$cmd $DESTDIR/usr/gnu/bin/$cmd
        logcmd ln -s ../../../../share/man/man1/g$cmd.1 $DESTDIR/usr/gnu/share/man/man1/$cmd.1
        logcmd ln -s ../../bin/g$cmd $DESTDIR/usr/sfw/bin/g$cmd
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
