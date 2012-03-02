#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=jpeg       # App name
VER=8d          # App version
PVER=1          # Package Version
PKG=image/library/libjpeg  # Package name (without prefix)
SUMMARY="jpeg - The Independent JPEG Groups JPEG software (v$VER)"
DESC="$SUMMARY"

DEPENDS_IPS="system/library"

CONFIGURE_OPTS="--enable-shared --disable-static"

# Turn the letter component of the version into a number for IPS versioning
ord26() {
    local ASCII=$(printf '%d' "'$1")
    ASCII=$((ASCII - 64))
    [[ $ASCII -gt 32 ]] && ASCII=$((ASCII - 32))
    echo $ASCII
}

save_function make_package make_package_orig
make_package() {
    if [[ -n "$USEIPS" ]]; then
        NUMVER=${VER::$((${#VER} -1))}
        ALPHAVER=${VER:$((${#VER} -1))}

        VER=${NUMVER}.$(ord26 ${ALPHAVER}) \
        make_package_orig
    else
        make_package_orig
    fi
}

init
download_source $PROG jpegsrc.v${VER}
patch_source
prep_build
build
make_isa_stub
fix_permissions
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
