#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=libpcap
VER=1.2.1
VERHUMAN=$VER
PVER=0.1
PKG=system/library/pcap
SUMMARY="libpcap - a packet capture library"
DESC="$SUMMARY"

CONFIGURE_OPTS="$CONFIGURE_OPTS --mandir=/usr/share/man"

save_function configure32 configure32_orig
save_function configure64 configure64_orig
configure32(){
    configure32_orig
    gsed -i 's/#define HAVE_NETPACKET_PACKET_H 1//;' config.h
}
configure64(){
    configure64_orig
    gsed -i 's/#define HAVE_NETPACKET_PACKET_H 1//;' config.h
}
fixup_man3(){
    mv $DESTDIR/usr/share/man/man3 $DESTDIR/usr/share/man/man3pcap
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
run_autoconf
build
make_isa_stub
fix_permissions
fixup_man3
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
