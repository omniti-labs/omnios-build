#############################################################################
# Download source tarball if needed and extract it
#############################################################################
# Parameters
#   $1 - directory name on the server
#   $2 - program name
#   $3 - program version
#   $4 - target directory
#
# E.g.
#       download_source myprog myprog 1.2.3 will try:
#       http://mirrors.omniti.com/myprog/myprog-1.2.3.tar.gz
download_source() {
    local DLDIR=$1
    local PROG=$2
    local VER=$3
    local TARGETDIR=$4
    if [[ -z $VER ]]; then
        local ARCHIVEPREFIX=$PROG
    else
        local ARCHIVEPREFIX=$PROG-$VER
    fi
    if [[ -z $TARGETDIR ]]; then
        # Default to $TMPDIR if no output dir specified
        TARGETDIR=$TMPDIR
    fi
    # Create TARGETDIR if it doesn't exist
    if [[ ! -d $TARGETDIR ]]; then
        logmsg "Specified target directory $TARGETDIR does not exist.  Creating it now."
        logcmd mkdir -p $TARGETDIR
    fi
    pushd $TARGETDIR > /dev/null
    logmsg "Checking for source directory"
    if [ -d $BUILDDIR ]; then
        logmsg "--- Source directory found"
        if check_for_patches "to see if we need to remove the source dir"; then
            logmsg "--- Patches are present, removing source directory"
            logcmd rm -rf $BUILDDIR || \
                logerr "Failed to remove source directory"
        else
            logmsg "--- Patches are not present, keeping source directory"
            popd > /dev/null
            return
        fi
    else
        logmsg "--- Source directory not found"
    fi

    # If we reach this point, the source directory was either not found, or it
    # was removed due to patches being present.
    logmsg "Checking for $PROG source archive"
    find_archive $ARCHIVEPREFIX FILENAME
    if [[ "$FILENAME" == "" ]]; then
        # Try all possible archive names
        logmsg "--- Archive not found."
        logmsg "Downloading archive"
        URLPREFIX=http://$MIRROR/$DLDIR/$ARCHIVEPREFIX
        $WGET -a $LOGFILE $URLPREFIX.tar.gz || \
            $WGET -a $LOGFILE $URLPREFIX.tar.bz2 || \
            $WGET -a $LOGFILE $URLPREFIX.tar.xz || \
            $WGET -a $LOGFILE $URLPREFIX.tgz || \
            $WGET -a $LOGFILE $URLPREFIX.tbz || \
            $WGET -a $LOGFILE $URLPREFIX.tar || \
            logerr "--- Failed to download file"
        find_archive $ARCHIVEPREFIX FILENAME
        if [[ "$FILENAME" == "" ]]; then
            logerr "Unable to find downloaded file."
        fi
    else
        logmsg "--- $PROG source archive found"
    fi


    # ----------------------
    #   MONKEYPATCH BEGIN
    # ----------------------

    # Oracle packages their tarball without a subdirectory
    mkdir $BUILDDIR
    pushd $BUILDDIR
    logmsg "Extracting archive: $FILENAME in " `pwd`
    if ! logcmd $TAR xzvf ../$FILENAME; then
        logerr "--- Unable to extract archive."
    fi
    popd > /dev/null

    # Make sure the archive actually extracted some source where we expect
    if [[ ! -e $BUILDDIR/$SVR4_PACKAGE_FILE ]]; then
        logerr "--- Extracted source is not in the expected location" \
            " ($BUILDDIR)"
    fi

    # ----------------------
    #   MONKEYPATCH END
    # ----------------------

    popd > /dev/null
}
