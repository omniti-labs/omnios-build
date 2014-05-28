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
# Copyright 2014 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#

show_usage() {
    echo "Usage: $0 [-h | -l | [-t TYPE] <NAME>]"
    echo "  -h      : Show usage summary"
    echo "  -l      : List available template types"
    echo "  -t TYPE : Optionally specify script type."
    echo "Creates a new build directory under $BUILDDIR called <NAME>"
    echo "and places a build script template in it."
}

if [[ -z $1 ]]; then
    show_usage
    exit 254
fi

SCRIPTDIR=`dirname $0`
BUILDDIR=$SCRIPTDIR/build
TYPESAVAIL="basic node perl python"
# Default type if not specified
TYPE="basic"
NAME=$1

while getopts "hlt:" opt; do
    case $opt in
        h)
            show_usage
            exit
            ;;
        l)
            echo "Valid types are: $TYPESAVAIL"
            exit 0
            ;;
        t)
            TYPE=$OPTARG
            NAME=$3
            if [[ "$TYPE" != "basic" && \
		  "$TYPE" != "node" && \
		  "$TYPE" != "perl" && \
		  "$TYPE" != "python" ]]; then
                echo "Unknown type: $TYPE"
                echo "Valid types are: $TYPESAVAIL"
                exit 2
            elif [[ -z $NAME ]]; then
                echo "No name specified."
                exit 2
            fi
            ;;
    esac
done

if [[ -d $BUILDDIR/$NAME ]]; then
    echo "Error: Directory $BUILDDIR/$NAME exists."
    exit 1
fi

year=`date +%Y`

echo "Creating new $TYPE build script under $BUILDDIR/$NAME"
mkdir $BUILDDIR/$NAME
cat $SCRIPTDIR/template/${TYPE}-template.sh | \
    sed -e "s/@@CYEAR@@/$year/" > $BUILDDIR/$NAME/build.sh
chmod +x $BUILDDIR/$NAME/build.sh
mkdir $BUILDDIR/$NAME/patches
