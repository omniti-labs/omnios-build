#!/usr/bin/bash

# Load support functions
. ../../lib/functions.sh

PROG=mercurial      # App name
VER=2.1   # App version
PVER=1        # Package Version
PKG=developer/versioning/mercurial # Package name (without prefix)
SUMMARY="$PROG - a free and open source, distributed version control system"
DESC="$SUMMARY"

DEPENDS_SVR4="OMNIpython26 OMNIcurl OMNIlibiconv OMNIopenssl OMNIzlib OMNIperl"
DEPENDS_IPS="runtime/python-26 \
             web/curl \
             library/security/openssl@1.0.0
             library/zlib"

# For inet_ntop which isn't detected properly in the configure script
CONFIGURE_OPTS=""

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

init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_package
clean_up
