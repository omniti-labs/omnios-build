#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=tcl
VER=8.5.10
PKG=omniti/runtime/tcl-8
SUMMARY="$PROG - a very powerful but easy to learn dynamic programming language"
DESC="$SUMMARY"

# We compile inside a subdir of the actual extracted dir. Changing builddir to
# pretend that this dir is the extracted dir is hacky, but works.
# Note - if we ever apply patches (triggering automatic removal of the build
# dir) then this may need to be changed so that tcl1.2.3 is deleted instead of
# tcl1.2.3/unix
BUILDDIR=$PROG$VER/unix

save_function configure64 configure64_orig
configure64(){
    CC="$CC -m64"
    CXX="$CXX -m64"
    export CC
    export CXX
    configure64_orig
}
move_man_to_share(){
    logcmd mkdir -p $DESTDIR$PREFIX/share
    logcmd mv $DESTDIR$PREFIX/man $DESTDIR$PREFIX/share
}

init
download_source $PROG $PROG$VER-src
patch_source
prep_build
build
make_isa_stub
move_man_to_share
make_package
clean_up
