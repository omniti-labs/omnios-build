#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=binutils               # App name
VER=2.22                    # App version
VERHUMAN=$VER               # Human-readable version
PVER=2                      # Package Version (numeric only)
PKG=developer/gnu-binutils  # Package name (without prefix)
SUMMARY="$PROG -  a collection of binary tools"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="gcc46"
[[ "$BUILDARCH" == "both" ]] && BUILDARCH=32

CONFIGURE_OPTS="--enable-gold=no --exec-prefix=/usr/gnu --program-prefix=g"

make_prog() {
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    logmsg "--- make"
    logcmd $MAKE SHELL=/bin/bash $MAKE_JOBS || \
        logerr "--- Make failed"
}

make_sfw_links() {
    logmsg "Creating SFW symlinks"
    logcmd mkdir -p $DESTDIR/$PREFIX/sfw/bin
    pushd $DESTDIR/$PREFIX/sfw/bin > /dev/null
    for file in gaddr2line gar gas gc++filt gelfedit ggprof gld gnm \
                gobjcopy gobjdump granlib greadelf gsize gstrings gstrip
        do logcmd ln -s ../../bin/$file $file || \
            logerr "Failed to create link for $file"
        done
    popd > /dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_sfw_links
fix_permissions
make_package
clean_up
