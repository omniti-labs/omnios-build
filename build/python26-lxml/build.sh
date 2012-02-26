#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PATH=/opt/gcc-4.6.2/bin:$PATH

PROG=lxml  # App name
VER=2.3.3        # App version
PVER=0.1
PKG=library/python-2/lxml-26 # Package name (without prefix)
SUMMARY="lxml - Powerful and Pythonic XML processing library"
DESC="$SUMMARY"

DEPENDS_IPS="runtime/python-26 library/libxml2 library/libxslt"

PYTHONPATH=/usr
PYTHON=$PYTHONPATH/bin/python2.6
PYTHONLIB=$PYTHONPATH/lib

python_build() {
    logmsg "Building using python setup.py"
    pushd $TMPDIR/$BUILDDIR > /dev/null

    ISALIST=i386
    export ISALIST
    logmsg "--- setup.py (32) build"
    logcmd $PYTHON ./setup.py build ||
        logerr "--- build failed"
    logmsg "--- setup.py (32) install"
    logcmd $PYTHON \
        ./setup.py install --root=$DESTDIR ||
        logerr "--- install failed"

    ISALIST="amd64 i386"
    export ISALIST
    logmsg "--- setup.py (64) build"
    logcmd $PYTHON ./setup.py build ||
        logerr "--- build failed"
    logmsg "--- setup.py (64) install"
    logcmd $PYTHON \
        ./setup.py install --root=$DESTDIR ||
        logerr "--- install failed"
    popd > /dev/null

    mv $DESTDIR/usr/lib/python2.6/site-packages $DESTDIR/usr/lib/python2.6/vendor-packages ||
        logerr "Cannot move from site-packages to vendor-packages"
}

ISALIST=i386
export ISALIST
init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
strip_install -x
ISALIST="i386 amd64"
export ISALIST
make_package
clean_up
