#!/usr/bin/bash

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

BUILDDIR=`dirname $0`/build
TYPESAVAIL="basic perl"
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
            if [[ "$TYPE" != "basic" && "$TYPE" != "perl" ]]; then
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

echo "Creating new $TYPE build script under $BUILDDIR/$NAME"
mkdir $BUILDDIR/$NAME
cp $BUILDDIR/template/${TYPE}-template.sh $BUILDDIR/$NAME/build.sh
chmod +x $BUILDDIR/$NAME/build.sh
mkdir $BUILDDIR/$NAME/patches
