#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=cdrtools   # App name
VER=3.00        # App version
VERHUMAN=$VER   # Human-readable version
PVER=1          # Package Version (numeric only)
PKG=media/cdrtools  # Package name (without prefix)
SUMMARY="CD creation utilities"
DESC="$SUMMARY ($VER)"

DEPENDS_IPS="system/library system/library/gcc-4-runtime"

MAKE="make"
BUILDARCH=32

# cdrtools doesn't use configure, just make
make_clean() {
    true
}
configure32() {
    true
}
make_install() {
    mkdir -p $DESTDIR/etc/security/exec_attr.d
    mkdir -p $DESTDIR/usr/bin
    mkdir -p $DESTDIR/usr/share/man/man1
    cp $SRCDIR/files/exec_attr $DESTDIR/etc/security/exec_attr.d
    cp $TMPDIR/$BUILDDIR/mkisofs/OBJ/i386-sunos5-gcc/mkisofs $DESTDIR/usr/bin/mkisofs
    mkdir -p $DESTDIR/usr/share/man/man8
    cp $TMPDIR/$BUILDDIR/mkisofs/mkisofs.8 $DESTDIR/usr/share/man/man8/mkisofs.8
    for cmd in cdda2wav cdrecord readcd ; do
        cp $SRCDIR/files/$cmd $DESTDIR/usr/bin/$cmd
        cp $TMPDIR/$BUILDDIR/$cmd/OBJ/i386-sunos5-gcc/$cmd $DESTDIR/usr/bin/$cmd.bin
        cp $TMPDIR/$BUILDDIR/$cmd/$cmd.1 $DESTDIR/usr/share/man/man1/$cmd.1
    done
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
