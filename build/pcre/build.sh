#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=pcre
VER=8.30
VERHUMAN=$VER
PVER=0.1
PKG=library/pcre
SUMMARY="Perl-Compatible Regular Expressions"
DESC="PCRE - Perl-Compatible Regular Expressions (8.30)"

DEPENDS_IPS="library/readline compress/bzip2 library/zlib system/library/g++-4-runtime
	system/library/gcc-4-runtime system/library system/library/math"

CONFIGURE_OPTS="$CONFIGURE_OPTS
	--includedir=/usr/include/pcre
	--localstatedir=/var
	--disable-static
	--enable-cpp
	--enable-rebuild-chartables
	--enable-utf8
	--enable-unicode-properties
	--enable-newline-is-any
	--disable-stack-for-recursion
	--enable-pcregrep-libz
	--enable-pcregrep-libbz2
	--with-posix-malloc-threshold=20
	--with-link-size=4
	--with-match-limit=10000000
	--with-pic
"

make_install64() {
    # the 32bit version installed these and the 64bit version will fail
    # reinstalling them... clear them out and let 64bit do its business.
    rm -rf $DESTDIR/usr/share/man
    make_install
}
install_license() {
    cp $TMPDIR/$BUILDDIR/LICENCE $DESTDIR/LICENSE
}

init
download_source $PROG $PROG $VER
patch_source
force_links
prep_build
build
make_isa_stub
fix_permissions
install_license
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
