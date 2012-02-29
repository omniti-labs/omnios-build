#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=gettext                  # App name
VER=0.18.1.1                  # App version
PVER=1                        # Package Version
PKG=text/gnu-gettext          # Package name (without prefix)
SUMMARY="gettext - GNU gettext utility"
DESC="GNU gettext - GNU gettext utility ($VER)"

NO_PARALLEL_MAKE=1
BUILDARCH=32

DEPENDS_IPS="developer/macro/gnu-m4"

CONFIGURE_OPTS="--infodir=$PREFIX/share/info
	--disable-java
	--disable-libasprintf
	--without-emacs
	--disable-openmp
	--disable-static
	--disable-shared
	--bindir=/usr/bin"

make_links() {
    logmsg "Creating GNU symlinks"
    logcmd mkdir -p $DESTDIR/$PREFIX/gnu/bin
    logcmd mkdir -p $DESTDIR/$PREFIX/gnu/share/man/man1
    for file in gettext msgfmt xgettext
    do
        logcmd mv $DESTDIR/$PREFIX/bin/$file $DESTDIR/$PREFIX/bin/g$file
        logcmd mv $DESTDIR/$PREFIX/share/man/man1/$file.1 $DESTDIR/$PREFIX/share/man/man1/g$file.1
        logcmd ln -s ../../bin/g$file $DESTDIR/$PREFIX/gnu/bin/$file
        logcmd ln -s ../../../../share/man/man1/g$file.1 $DESTDIR/$PREFIX/gnu/share/man/man1/$file
    done
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_links
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
