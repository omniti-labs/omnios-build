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
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#
#############################################################################
# Configuration for the build system
#############################################################################

# Default branch
RELVER=151006
PVER=0.$RELVER

# Which server to fetch files from
MIRROR=mirrors.omniti.com

# Default prefix for packages (may be overridden)
PREFIX=/usr

# Temporary directories
# TMPDIR is used for source archives and build directories
#    to avoid collision on shared build systems,
#    TMPDIR includes a username
# DTMPDIR is used for constructing the DESTDIR path
TMPDIR=/tmp/build_$USER
DTMPDIR=$TMPDIR

# Log file for all output
LOGFILE=$PWD/build.log

# Default patches dir
PATCHDIR=patches

# Do we create isaexec stubs for scripts and other non-binaries (default yes)
NOSCRIPTSTUB=

#############################################################################
# Perl stuff
#############################################################################

# Perl versions we currently build against
PERLVERLIST="5.16.1"

# Full paths to bins
PERL32=/usr/perl5/5.16.1/bin/$ISAPART/perl
PERL64=/usr/perl5/5.16.1/bin/$ISAPART64/perl

# Default Makefile.PL options
PERL_MAKEFILE_OPTS="INSTALLSITEBIN=$PREFIX/bin/_ARCHBIN_ \
                    INSTALLSITESCRIPT=$PREFIX/bin/_ARCHBIN_ \
                    INSTALLSITEMAN1DIR=$PREFIX/share/man/man1 \
                    INSTALLSITEMAN3DIR=$PREFIX/share/man/man3 \
                    INSTALLDIRS=site"

# Accept MakeMaker defaults so as not to stall build scripts
export PERL_MM_USE_DEFAULT=true

# When building perl modules, run make test
# Unset in a build script to skip tests
PERL_MAKE_TEST=1

#############################################################################
# Python
#############################################################################
PYTHONPATH=/usr
PYTHON=$PYTHONPATH/bin/python2.6
PYTHONLIB=$PYTHONPATH/lib


#############################################################################
# Paths to common tools
#############################################################################
WGET=wget
PATCH=gpatch
MAKE=gmake
TAR=tar
GZIP=gzip
BUNZIP2=bunzip2
XZCAT=xzcat
UNZIP=unzip
AWK=gawk
SUDO=sudo

# Figure out number of logical CPUs for use with parallel gmake jobs (-j)
# Default to 1.5*nCPUs as we assume the build machine is 100% devoted to
# compiling.  
# A build script may serialize make by setting NO_PARALLEL_MAKE
LCPUS=`psrinfo | wc -l`
MJOBS="$[ $LCPUS + ($LCPUS / 2) ]"
if [ "$MJOBS" == "0" ]; then
    MJOBS=2
fi
MAKE_JOBS="-j $MJOBS"
NO_PARALLEL_MAKE=

# Remove install or packaging files by default. You can set this in a build
# script when testing to speed up building a package
DONT_REMOVE_INSTALL_DIR=

#############################################################################
# C compiler options - these can be overriden by a build script
#############################################################################
# isaexec(3C) variants
# These variables will be passed to the build to construct multi-arch 
# binary and lib directories in DESTDIR

ISAPART=i386
ISAPART64=amd64

# For OmniOS we (almost) always want GCC
CC=gcc
CXX=g++

# CFLAGS applies to both builds, 32/64 only gets applied to the respective
# build
CFLAGS=""
CFLAGS32=""
CFLAGS64="-m64"

# Linker flags
LDFLAGS=""
LDFLAGS32=""
LDFLAGS64="-m64"

# C pre-processor flags
CPPFLAGS=""
CPPFLAGS32=""
CPPFLAGS64=""

# C++ flags
CXXFLAGS=""
CXXFLAGS32=""
CXXFLAGS64="-m64"

#############################################################################
# Configuration of the packaged software
#############################################################################
# Default configure command - almost always sufficient
CONFIGURE_CMD="./configure"

# Default configure options - replace/add to as needed
# This is a function so it can be called again if you change $PREFIX
# This is far from ideal, but works
reset_configure_opts() {
    # If it's the global default (/usr), we want sysconfdir to be /etc
    # otherwise put it under PREFIX
    if [[ $PREFIX == "/usr" ]]; then
        SYSCONFDIR=/etc
    else
        SYSCONFDIR=$PREFIX/etc
    fi
    CONFIGURE_OPTS_32="--prefix=$PREFIX
        --sysconfdir=$SYSCONFDIR
        --includedir=$PREFIX/include
        --bindir=$PREFIX/bin/$ISAPART
        --sbindir=$PREFIX/sbin/$ISAPART
        --libdir=$PREFIX/lib
        --libexecdir=$PREFIX/libexec"

    CONFIGURE_OPTS_64="--prefix=$PREFIX
        --sysconfdir=$SYSCONFDIR
        --includedir=$PREFIX/include/$ISAPART64
        --bindir=$PREFIX/bin/$ISAPART64
        --sbindir=$PREFIX/sbin/$ISAPART64
        --libdir=$PREFIX/lib/$ISAPART64
        --libexecdir=$PREFIX/libexec/$ISAPART64"
}
reset_configure_opts

# Configure options to apply to both builds - this is the one you usually want
# to change for things like --enable-feature
CONFIGURE_OPTS=""

# Vim hints
# vim:ts=4:sw=4:et:
