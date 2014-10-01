#!/usr/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#

#
# Copyright (c) 2013 by Delphix. All rights reserved.
#

# Load support functions
. ../../lib/functions.sh

# Patches are synced from gnu.org, e.g.
#   rsync -a --exclude=*.sig rsync://ftp.gnu.org/ftp/bash/bash-4.3-patches/ patches/bash-4.3-patches/
#   cd patches
#   ls bash-4.3-patches/* | sed -e 's/\([0-9]\)$/\1 -p0/' > series
# Then set PATCHLEVEL to the highest patch number in the updated list
#
# NOTE: patches will obviously have to be checked often.

PROG=bash       # App name
VER=4.3         # App version
PATCHLEVEL=28   # Patch level
VERHUMAN="$VER patchlevel $PATCHLEVEL"
PKG=shell/bash  # Package name (without prefix)
SUMMARY="GNU Bourne-Again shell (bash)"
DESC="$SUMMARY version $VER"

DEPENDS_IPS="system/library system/library/gcc-4-runtime"

BUILDARCH=32
NO_PARALLEL_MAKE=1

# Cribbed from upstream but modified for gcc
# "let's shrink the SHT_SYMTAB as much as we can"
LDFLAGS="-Wl,-z -Wl,redlocsym"

# Cribbed from upstream, with a few changes:
#   We only do 32-bit so forgo the isaexec stuff
#   Don't bother building static
CONFIGURE_OPTS="
    --bindir=$PREFIX/bin
    --localstatedir=/var
    --enable-alias
    --enable-arith-for-command
    --enable-array-variables
    --enable-bang-history   
    --enable-brace-expansion    
    --enable-casemod-attributes 
    --enable-casemod-expansions 
    --enable-command-timing 
    --enable-cond-command   
    --enable-cond-regexp    
    --enable-coprocesses    
    --enable-debugger   
    --enable-directory-stack    
    --enable-disabled-builtins  
    --enable-dparen-arithmetic  
    --enable-extended-glob  
    --enable-help-builtin   
    --enable-history    
    --enable-job-control    
    --enable-multibyte  
    --enable-net-redirections   
    --enable-process-substitution   
    --enable-progcomp   
    --enable-prompt-string-decoding 
    --enable-readline   
    --enable-restricted 
    --enable-select 
    --enable-separate-helpfiles 
    --enable-single-help-strings    
    --disable-strict-posix-default  
    --enable-usg-echo-default   
    --enable-xpg-echo-default   
    --enable-mem-scramble   
    --disable-profiling 
    --enable-largefile
    --enable-nls    
    --with-bash-malloc  
    --with-curses   
    --with-installed-readline=no    
"
reset_configure_opts

# Files pilfered from upstream userland-gate
install_files() {
    logmsg "Installing extra files"
    logcmd cp $MYDIR/files/rbash.1 $DESTDIR$PREFIX/share/man/man1/
    logcmd mkdir -p $DESTDIR/etc/bash
    logcmd mkdir -p $DESTDIR/etc/skel
    logcmd cp $MYDIR/files/etc.bash.bash_completion $DESTDIR/etc/bash/bash_completion
    logcmd cp $MYDIR/files/etc.bash.bashrc $DESTDIR/etc/bash/bashrc.example
    logcmd cp $MYDIR/files/etc.bash.inputrc $DESTDIR/etc/bash/inputrc.example
    logcmd cp $MYDIR/files/etc.skel.bashrc $DESTDIR/etc/skel/.bashrc
}

make_symlink() {
    logmsg "Setting up symlinks"
    logcmd ln -s ./bash $DESTDIR$PREFIX/bin/rbash
    logcmd mkdir -p $DESTDIR$PREFIX/gnu/bin
    logcmd ln -s ../../bin/bash $DESTDIR$PREFIX/gnu/bin/sh
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
install_files
make_symlink
VER=${VER}.$PATCHLEVEL
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
