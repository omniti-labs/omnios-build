#!/bin/bash
#############################################################################
# functions.sh
#############################################################################
# Helper functions for building packages that should be common to all build
# scripts
#############################################################################
#
# Directory layout
#   lib/
#       functions.sh - library helper functions
#   build/
#       packagename/
#           build.sh - the build script
#           patches/ - directory containing patches
#   packages/        - contains built packages - not stored in svn

#############################################################################
# Process command line options
#############################################################################
process_opts() {
    SCREENOUT=
    FLAVOR=
    OLDFLAVOR=
    BUILDARCH=both
    OLDBUILDARCH=
    BATCH=
    DEPVER=
    while getopts "bpf:ha:d:" opt; do
        case $opt in
            h)
                show_usage
                exit
                ;;
            \?)
                show_usage
                exit 2
                ;;
            p)
                SCREENOUT=1
                ;;
            b)
                BATCH=1 # Batch mode - exit on error
                ;;
            f)
                FLAVOR=$OPTARG
                OLDFLAVOR=$OPTARG # Used to see if the script overrides the
                                   # flavor
                ;;
            a)
                BUILDARCH=$OPTARG
                OLDBUILDARCH=$OPTARG # Used to see if the script overrides the
                                     # BUILDARCH variable
                if [[ "$BUILDARCH" != "32" && "$BUILDARCH" != "64" &&
                      "$BUILDARCH" != "both" ]]; then
                    echo "Invalid build architecture specified: $BUILDARCH"
                    show_usage
                    exit 2
                fi
		;;
            d)
	        DEPVER=$OPTARG
                ;;
        esac
    done
}

#############################################################################
# Show usage information
#############################################################################
show_usage() {
    echo "Usage: $0 [-b] [-p] [-f FLAVOR] [-h] [-a 32|64|both] [-d DEPVER]"
    echo "  -b        : batch mode (exit on errors without asking)"
    echo "  -p        : output all commands to the screen as well as log file"
    echo "  -f FLAVOR : build a specific package flavor"
    echo "  -h        : print this help text"
    echo "  -a ARCH   : build 32/64 bit only, or both (default: both)"
    echo "  -d DEPVER : specify an extra dependency version (no default)"
}

#############################################################################
# Log output of a command to a file
#############################################################################
logcmd() {
    if [[ -z "$SCREENOUT" ]]; then
        echo Running: "$@" >> $LOGFILE
        "$@" >> $LOGFILE 2>&1
    else
        echo Running: "$@" | tee $LOGFILE
        "$@" | tee $LOGFILE 2>&1
    fi
}
logmsg() {
    echo "$@" >> $LOGFILE
    echo "$@"
}
logerr() {
    # Print an error message and ask the user if they wish to continue
    logmsg $@
    if [[ -z $BATCH ]]; then
        ask_to_continue
    else
        exit 1
    fi
}
ask_to_continue() {
    # Ask the user if they want to continue or quit in the event of an error
    echo -n "An Error occured in the build. Do you wish to continue anyway? (y/n) "
    read
    while [[ ! "$REPLY" =~ [yYnN] ]]; do
        echo -n "continue? (y/n) "
        read
    done
    if [[ "$REPLY" == "n" || "$REPLY" == "N" ]]; then
        logmsg "===== Build aborted ====="
        exit 1
    fi
    logmsg "===== Error occured, user chose to continue anyway. ====="
}

#############################################################################
# URL encoding for package names, at least
#############################################################################
# This isn't real URL encoding, just a couple of common substitutions
url_encode() {
    [ $# -lt 1 ] && logerr "Not enough arguments to url_encode().  Expecting a string to encode."
    local encoded="$1";
    encoded=`echo $encoded | sed -e 's!/!%2F!g' -e 's!+!%2B!g'`
    echo $encoded
}

#############################################################################
# Some initialization
#############################################################################
# Set the LANG to C as the assembler will freak out on unicode in headers
LANG=C
export LANG
# Set the path - This can be overriden/extended in the build script
PATH="/opt/gcc-4.6.2/bin:/opt/omni/bin:/usr/ccs/bin:/usr/bin:/usr/sbin:/usr/sfw/bin:/opt/csw/bin"
export PATH
# The dir where this file is located - used for sourcing further files
MYDIR=$PWD/`dirname $BASH_SOURCE[0]`
# The dir where this file was sourced from - this will be the directory of the
# build script
SRCDIR=$PWD/`dirname $0`

#############################################################################
# Load configuration options
#############################################################################
. $MYDIR/config.sh
process_opts $@

#############################################################################
# Make sure we are running as root
#############################################################################
if [[ "$UID" != "0" ]]; then
    logerr "--- This build script should be run as root or via sudo"
fi

#############################################################################
# Print startup message
#############################################################################
logmsg "===== Build started at `date` ====="
#############################################################################
# Initialization function
#############################################################################
init() {
    # Platform information
    PLATFORM=`uname -p` # i386/sparc
    SUNOSVER=`uname -r` # 5.10/5.11 (only used for IPS)
    RELEASE=${SUNOSVER/5./sol} # sol9/sol10/sol11

    # Print out current settings
    # Package format
    if [[ "$PKGFMT" == "SVR4" ]]; then
        logmsg "Package format: SVR4"
    elif [[ "$PKGFMT" == "IPS" ]]; then
        logmsg "Package format: IPS"
        USEIPS=true
    else
        logerr "Package format must be SVR4 or IPS.  Current setting is '$PKGFMT'"
    fi
    # Selected flavor
    if [[ -z "$FLAVOR" ]]; then
        logmsg "Selected flavor: None (use -f to specify a flavor)"
    else
        logmsg "Selected Flavor: $FLAVOR"
    fi
    if [[ -n "$OLDFLAVOR" && "$OLDFLAVOR" != "$FLAVOR" ]]; then
        logmsg "NOTICE - The flavor was overridden by the build script."
        logmsg "The flavor specified on the command line was: $OLDFLAVOR"
    fi
    # Build arch
    logmsg "Selected build arch: $BUILDARCH"
    if [[ -n "$OLDBUILDARCH" && "$OLDBUILDARCH" != "$BUILDARCH" ]]; then
        logmsg "NOTICE - The build arch was overridden by the build script."
        logmsg "The build arch specified on the command line was: $OLDFLAVOR"
    fi
    # Extra dependency version
    if [[ -z "$DEPVER" ]]; then
	logmsg "Extra dependency: None (use -d to specify a version)"
    else
        logmsg "Extra dependency: $DEPVER"
    fi

    # BUILDDIR can be used to manually specify what directory the program is
    # built in (i.e. what the tarball extracts to). This defaults to the name
    # and version of the program, which works in most cases.
    if [[ -z $BUILDDIR ]]; then
        BUILDDIR=$PROG-$VER
    fi

    verify_depends
}

#############################################################################
# Verify any dependencies
#############################################################################
verify_depends() {
    logmsg "Verifying dependencies"
    if [[ -n "$DEPENDS" || -n "$BUILD_DEPENDS" ]]; then
        logmsg "--- ***WARNING*** DEPENDS/BUILD_DEPENDS are deprecated. Please update your build script to use SVR4- and IPS-specific variables."
    fi
    if [[ -n "$USEIPS" ]]; then
        [[ -z "$DEPENDS_IPS" ]] && DEPENDS_IPS=$DEPENDS
        for i in $DEPENDS_IPS; do
            # Trim indicators to get the true name (see make_package for details)
            case ${i:0:1} in
                \=|\?)
                    i=${i:1}
                    ;;
                \-)
                    # If it's an exclude, we should error if it's installed rather than missing
                    i=${i:1}
                    pkg info $i > /dev/null 2<&1 &&
                        logerr "--- Excluded dependency $i cannot be installed with this package."
                    continue
                    ;;
            esac
            pkg info $i > /dev/null 2<&1 ||
                logerr "--- Package dependency $i not found"
        done
        for i in $BUILD_DEPENDS_IPS; do
            pkg info $i > /dev/null 2<&1 ||
                logerr "--- Build-time dependency $i not found"
        done
    else
        [[ -z "$DEPENDS_SVR4" ]] && DEPENDS_SVR4=$DEPENDS
        if `pkginfo OMNIzlib > /dev/null 2>&1`; then
            logerr "--- OMNIzlib is installed.  We are avoiding mixing system and OMNI versions of libz.  Please uninstall OMNIzlib."
        fi
        for i in $DEPENDS_SVR4; do
            pkginfo -q $i ||
                logerr "--- Package dependency $i not found"
        done
        for i in $BUILD_DEPENDS_SVR4; do
            pkginfo -q $i ||
                logerr "--- Build-time dependency $i not found"
        done
    fi
}

#############################################################################
# People that need this should call it explicitly
#############################################################################
run_autoconf() {
    logmsg "Running autoconf"
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd autoconf || logerr "Failed to run autoconf"
    popd > /dev/null
}

#############################################################################
# Stuff that needs to be done/set before we start building
#############################################################################
prep_build() {
    logmsg "Preparing for build"

    # Get the current date/time for the package timestamp
    if [[ -n "$USEIPS" ]]; then
        DATETIME=`TZ=UTC /usr/bin/date +"%Y%m%dT%H%M%SZ"`
        if [[ -d /usr/include/openssl && -z $USE_SYSTEM_SSL_HEADERS ]]; then
            mv /usr/include/openssl /usr/include/openssl.omnibuild.safety
        fi
    else
        pkginfo SUNWopenssl-include > /dev/null 2>&1 && \
            logerr "You have other openssl headers installed. Wicked bad."
        DATETIME=`/usr/bin/date +"%Y%m%d%H%M"`
    fi

    logmsg "--- Creating temporary install dir"
    # We might need to encode some special chars
    PKGE=$(url_encode $PKG)
    DESTDIR=$DTMPDIR/${PKGE}_pkg
    if [[ -z $DONT_REMOVE_INSTALL_DIR ]]; then
        logcmd rm -rf $DESTDIR || \
            logerr "Failed to remove old temporary install dir"
        mkdir $DESTDIR || \
            logerr "Failed to create temporary install dir"
    fi
}

#############################################################################
# Applies patches contained in $PATCHDIR (default patches/)
#############################################################################
check_for_patches() {
    if [[ -z $1 ]]; then
        logmsg "Checking for patches in $PATCHDIR/"
    else
        logmsg "Checking for patches in $PATCHDIR/ ($1)"
    fi
    if [[ ! -d $SRCDIR/$PATCHDIR ]]; then
        logmsg "--- No patches directory found"
        return 1
    fi
    if [[ ! -f $SRCDIR/$PATCHDIR/series ]]; then
        logmsg "--- No series file (list of patches) found"
        return 1
    fi
    return 0
}
patch_source() {
    if ! check_for_patches "in order to apply them"; then
        logmsg "--- Not applying any patches"
    else
        logmsg "Applying patches"
        # Read the series file for patch filenames
        exec 3<"$SRCDIR/$PATCHDIR/series" # Open the series file with handle 3
        pushd $TMPDIR/$BUILDDIR > /dev/null
        while read LINE <&3 ; do
            # Split Line into filename+args
            patch_file $LINE
        done
        popd > /dev/null
        exec 3<&- # Close the file
    fi
}

patch_file() {
    FILENAME=$1
    shift
    ARGS=$@
    if [[ ! -f $SRCDIR/$PATCHDIR/$FILENAME ]]; then
        logmsg "--- Patch file $FILENAME not found. Skipping patch."
        return
    fi
    # Note - if -p is specified more than once, then the last one takes
    # precedence, so we can specify -p1 at the beginning to default to -p1.
    # -t - don't ask questions
    # -N - don't try to apply a reverse patch
    if ! logcmd $PATCH -p1 -t -N $ARGS < $SRCDIR/$PATCHDIR/$FILENAME; then
        logerr "--- Patch $FILENAME failed"
    else
        logmsg "--- Applied patch $FILENAME"
    fi
}

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
    # Extract the archive
    logmsg "Extracting archive: $FILENAME"
    if ! logcmd extract_archive $FILENAME; then
        logerr "--- Unable to extract archive."
    fi
    # Make sure the archive actually extracted some source where we expect
    if [[ ! -d $BUILDDIR ]]; then
        logerr "--- Extracted source is not in the expected location" \
            " ($BUILDDIR)"
    fi
    popd > /dev/null
}

# Finds an existing archive and stores its value in a variable whose name
#   is passed as a second parameter
# Example: find_archive myprog-1.2.3 FILENAME
#   Stores myprog-1.2.3.tar.gz in $FILENAME
find_archive() {
    FILES=`ls $1.{tar.bz2,tar.gz,tgz,tbz,tar} 2>/dev/null`
    FILES=${FILES%% *} # Take only the first filename returned
    # This dereferences the second parameter passed
    eval "$2=\"$FILES\""
}

# Extracts an archive regardless of its extension
extract_archive() {
    if [[ ${1: -7} == ".tar.gz" || ${1: -4} == ".tgz" ]]; then
        $GZIP -dc $1 | $TAR xvf -
    elif [[ ${1: -8} == ".tar.bz2" || ${1: -4} == ".tbz" ]]; then
        $BUNZIP2 -dc $1 | $TAR xvf -
    elif [[ ${1: -4} == ".tar" ]]; then
        $TAR xvf $1
    else
        return 1
    fi
}

fix_permissions() {
    # Make everything owned by root
    # This is just in case files are installed as non-root even when run via
    # sudo. We haven't come across a situation where we need files installed
    # as a non-root user. If those come up, this function will have to be
    # overridden.
    logmsg "Fixing ownership on installed files"

    # -P says don't follow symlinks
    logcmd chown -R -P root:root ${DESTDIR} ||
        logerr "Failed to fix ownership on ${DESTDIR}"
}

#############################################################################
# Make the package
#############################################################################
make_package() {
    logmsg "Making package"
    case $BUILDARCH in
        32)
            BUILDSTR="32bit-"
            ;;
        64)
            BUILDSTR="64bit-"
            ;;
        *)
            BUILDSTR=""
            ;;
    esac
    # Add the flavor name to the package if it is not the default
    case $FLAVOR in
        ""|default)
            FLAVORSTR=""
            ;;
        *)
            FLAVORSTR="$FLAVOR-"
            ;;
    esac
    DESCSTR="$DESC"
    if [[ -n "$BUILDSTR" ]]; then
        DESCSTR="$DESCSTR (${BUILDSTR}only)"
    fi
    if [[ -n "$FLAVORSTR" ]]; then
        DESCSTR="$DESCSTR ($FLAVOR)"
    fi
    if [[ -n "$USEIPS" ]]; then
        ## Strip leading zeros in version components.
        VER=`echo $VER | sed -e 's/\.0*\([1-9]\)/.\1/g;'`
	if [[ -n "$FLAVOR" ]]; then
	    # We use FLAVOR here because we don't need the trailing dash as in SVR4
            PUBLISHCMD="pkgsend -s $PKGSRVR open -n ${PKGPREFIX}${PKG}-${FLAVOR}@${VER},${SUNOSVER}-${PVER}"
	else
            PUBLISHCMD="pkgsend -s $PKGSRVR open -n ${PKGPREFIX}${PKG}@${VER},${SUNOSVER}-${PVER}"
	fi
        logmsg "Opening new package transaction with '$PUBLISHCMD'"
        logcmd export PKG_TRANS_ID=$($PUBLISHCMD || echo "ERROR")
        if [[ "$PKG_TRANS_ID" == "ERROR" ]]; then
            logerr "Failed to open new package transaction"
        fi
        # Set human-readable version, if it exists
        if [[ -n "$VERHUMAN" ]]; then
            logmsg "Setting human-readable version"
            logcmd pkgsend -s $PKGSRVR add set name=pkg.human-version value="$VERHUMAN"
        fi
        # If DESTDIR is unset, then we're probably making a metapackage
        #   so there won't be anything to import
        if [[ -n "$DESTDIR" ]]; then
            logmsg "Sending files from $DESTDIR"
            if logcmd pkgsend -s $PKGSRVR import $DESTDIR; then
		logmsg "--- Finished sending files"
            else
		logcmd pkgsend -s $PKGSRVR close -A
                logmsg "Aborting: Failed to send pkg correctly"
		exit
            fi
        fi
        logcmd pkgsend -s $PKGSRVR add set name=pkg.summary value="$SUMMARY"
        logcmd pkgsend -s $PKGSRVR add set name=pkg.descr value="$DESCSTR"
        logcmd pkgsend -s $PKGSRVR add set name=publisher value="sa@omniti.com"
        if [[ -n "$DEPENDS_IPS" ]]; then
            logmsg "Adding dependencies"
            for i in $DEPENDS_IPS; do
                # IPS dependencies have multiple types, of which we care about four:
                #    require, optional, incorporate, exclude
                # For backward compatibility, assume no indicator means type=require
                # FMRI attributes are implicitly rooted so we don't have to prefix
                # 'pkg:/' or worry about ambiguities in names
                local DEPTYPE="require"
                case ${i:0:1} in
                    \=)
                        DEPTYPE="incorporate"
                        i=${i:1}
                        ;;
                    \?)
                        DEPTYPE="optional"
                        i=${i:1}
                        ;;
                    \-)
                        DEPTYPE="exclude"
                        i=${i:1}
                        ;;
                esac
                logcmd pkgsend -s $PKGSRVR add depend type=$DEPTYPE fmri=${i}
            done
        fi
        logmsg "Closing package transaction"
        logcmd pkgsend -s $PKGSRVR close
    else
        PKGFILE=${PKGPREFIX}$PKG-$FLAVORSTR$VER-$PVER-$PLATFORM-$BUILDSTR$RELEASE
        local PKGINFODIR=/var/tmp/$PROG.pkginfo.$$
        logcmd rm -rf $PKGINFODIR || \
            logerr "Failed to remove dir $PKGINFODIR"
        logcmd mkdir $PKGINFODIR || \
            logerr "Failed to mkdir $PKGINFODIR"
        pushd $PKGINFODIR > /dev/null

        make_prototype

        logcmd pkgmk -o -r $DESTDIR -d . || \
            logerr "--- Failed to make the package"
        if [[ -z "$DISABLE_PKGZIP" ]]; then
            logmsg "--- Compressing package using bzip2"
            logcmd $MYDIR/../tools/pkgzip -b ${PKGPREFIX}$PKG || \
                logerr "--- Failed to compress package"
        else
            logmsg "--- Package compression disabled - skipping compression"
        fi
        logmsg "--- Translating package to datastream format"
        logcmd pkgtrans . $OUTDIR/$PKGFILE \
            ${PKGPREFIX}$PKG || \
            logerr "--- Failed to translate package"

        popd > /dev/null

        logcmd rm -rf $PKGINFODIR || \
            logerr "Failed to remove dir $PKGINFODIR"
    fi
}

#############################################################################
# Generate dependencies file (SVR4 only)
#############################################################################
generate_depends_svr4() {
    if [[ -z $DEPENDS_SVR4 ]]; then
        logmsg "------ No dependecies specified. Skipping dependency file"
        return 1
    fi
    logmsg "------ Generating dependencies file"
    local DEPENDSFILE=depend
    # Clear any existing depends file
    >$DEPENDSFILE
    for i in $DEPENDS_SVR4; do
        pkginfo $i >> $DEPENDSFILE ||
            logerr "--- Package $i not found"
    done
    sed 's/^[a-zA-Z]* */P /' $DEPENDSFILE > $DEPENDSFILE.tmp
    mv $DEPENDSFILE.tmp $DEPENDSFILE
}

#############################################################################
# Make package prototype
#############################################################################
make_prototype() {
    # Set the variables named below to override the default values
    [[ -z "$SUMMARY" ]] && SUMMARY="$PROG for Solaris"
    [[ -z "$DESC" && -z "$DESCSTR" ]] && DESCSTR="OmniTI roll of $PROG"
    [[ -z "$CATEGORY" ]] && CATEGORY="application"
    [[ -z "$VENDOR" ]] && VENDOR="http://www.omniti.com"
    [[ -z "$EMAIL" ]] && EMAIL="sa@omniti.com"
    logmsg "--- Building package meta info"
    cat <<EOF > pkginfo
PKG=${PKGPREFIX}$PKG
NAME="$SUMMARY"
CATEGORY=$CATEGORY
ARCH=$PLATFORM
VERSION=${VER}-${PVER}
DESC="$DESCSTR"
VENDOR="$VENDOR"
EMAIL="$EMAIL"
BASEDIR=/
PSTAMP="$HOSTNAME-$DATETIME"
EOF
    echo "i pkginfo" > prototype
    # Add install scripts if any - the INSTALL_SCRIPTS variable is set in the
    # add_install_scripts function
    add_install_scripts && for i in $INSTALL_SCRIPTS; do
        echo "i $i" >> prototype
    done
    generate_depends_svr4 && \
        echo "i depend" >> prototype
    #echo "d none opt ? ? ?" >> prototype
    find $DESTDIR/* | pkgproto | \
        $AWK "
        BEGIN {
            prefix = substr(\"$PREFIX\", 2)
            path = \"${DESTDIR}/?\"
        }

        # Remove the /var/tmp prefix
        { sub( path, \"\", \$3) }
        # Remove any prefix for symlinks too
        { sub( path, \"/\", \$3) }

        # Fix permissions on $PREFIX paths
        \$3 && prefix ~ \$3 {
            printf \"%s %s %s ? ? ?\n\", \$1, \$2, \$3
            next
        }

        { print }
        " >> prototype
}

#############################################################################
# Looks for any pre/post install scripts and adds them to the package
#############################################################################
add_install_scripts() {
    local i
    INSTALL_SCRIPTS=""
    logmsg "------ Checking for install scripts to add"
    for i in $SRCDIR/scripts/*; do
        if [[ -f $i ]]; then
            logmsg "--------- $i"
            # Append $i to the install_scripts array
            INSTALL_SCRIPTS="$INSTALL_SCRIPTS `basename $i`"
            cp $i .
        fi
    done
    if [[ $INSTALL_SCRIPTS == "" ]]; then
        logmsg "--------- No install scripts found"
        return 1
    fi
}

#############################################################################
# Make isa stub binaries
#############################################################################
make_isa_stub() {
    logmsg "Making isaexec stub binaries"
    [[ -z $ISAEXEC_DIRS ]] && ISAEXEC_DIRS="bin sbin"
    for DIR in $ISAEXEC_DIRS; do
        if [[ -d $DESTDIR$PREFIX/$DIR ]]; then
            logmsg "--- $DIR"
            pushd $DESTDIR$PREFIX/$DIR > /dev/null
            make_isaexec_stub_arch $ISAPART
            make_isaexec_stub_arch $ISAPART64
            popd > /dev/null
        fi
    done
}

make_isaexec_stub_arch() {
    for file in $1/*; do
        [[ -f $file ]] || continue # Deals with empty dirs & non-files
        # Check to make sure we don't have a script
        read -n 5 < $file
        file=`echo $file | sed -e "s/$1\///;"`
        # Skip if we already made a stub for this file
        [[ -f $file ]] && continue
        # Only copy non-binaries if we set NOSCRIPTSTUB
        if [[ $REPLY != $'\177'ELF && -n "$NOSCRIPTSTUB" ]]; then
            logmsg "------ Non-binary file: $file - copying instead"
            cp $1/$file .
            chmod +x $file
            continue
        fi
        logmsg "------ $file"
        # Run the makeisa.sh script
        CC=$CC \
        logcmd $MYDIR/makeisa.sh $PREFIX/$DIR $file || \
            logerr "--- Failed to make isaexec stub for $DIR/$file"
    done
}

#############################################################################
# Build commands
#############################################################################
# Notes:
#   - These methods are designed to work in the general case.
#   - You can set CFLAGS/LDFLAGS (and CFLAGS32/CFLAGS64 for arch specific flags)
#   - Configure flags are set in CONFIGURE_OPTS_32 and CONFIGURE_OPTS_64 with
#   defaults set in config.sh. You can append to these variables, replace them
#   if the defaults don't work for you.
#   - In the 'normal' case, where you just want to add --enable-feature, set
#   CONFIGURE_OPTS. This will be appended to the end of CONFIGURE_CMD
#   for both 32 and 64 bit builds.
#   - Any of these functions can be overriden in your build script, so if
#   anything here doesn't apply to the build process for your application,
#   just override that function with whatever code you need. The build
#   function itself can be overriden if the build process doesn't fit into a
#   configure, make, make install pattern.
#############################################################################
make_clean() {
    logmsg "--- make (dist)clean"
    logcmd $MAKE distclean || \
    logcmd $MAKE clean || \
        logmsg "--- *** WARNING *** make (dist)clean Failed"
}

configure32() {
    logmsg "--- configure (32-bit)"
    CFLAGS="$CFLAGS $CFLAGS32" \
    CXXFLAGS="$CXXFLAGS $CXXFLAGS32" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS32" \
    LDFLAGS="$LDFLAGS $LDFLAGS32" \
    CC=$CC CXX=$CXX \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_32 \
    $CONFIGURE_OPTS || \
        logerr "--- Configure failed"
}

configure64() {
    logmsg "--- configure (64-bit)"
    CFLAGS="$CFLAGS $CFLAGS64" \
    CXXFLAGS="$CXXFLAGS $CXXFLAGS64" \
    CPPFLAGS="$CPPFLAGS $CPPFLAGS64" \
    LDFLAGS="$LDFLAGS $LDFLAGS64" \
    CC=$CC CXX=$CXX \
    logcmd $CONFIGURE_CMD $CONFIGURE_OPTS_64 \
    $CONFIGURE_OPTS || \
        logerr "--- Configure failed"
}

make_prog() {
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    logmsg "--- make"
    logcmd $MAKE $MAKE_JOBS || \
        logerr "--- Make failed"
}

make_install() {
    logmsg "--- make install"
    logcmd $MAKE DESTDIR=${DESTDIR} install || \
        logerr "--- Make install failed"
}

make_pure_install() {
    # Make pure_install for perl modules so they don't touch perllocal.pod
    logmsg "--- make install (pure)"
    logcmd $MAKE DESTDIR=${DESTDIR} pure_install || \
        logerr "--- Make pure_install failed"
}

make_param() {
    logmsg "--- make $@"
    logcmd $MAKE "$@" || \
        logerr "--- $MAKE $1 failed"
}

# Helper function that can be called by build scripts to make in a specific dir
make_in() {
    [[ -z $1 ]] && logerr "------ Make in dir failed - no dir specified"
    [[ -n $NO_PARALLEL_MAKE ]] && MAKE_JOBS=""
    logmsg "------ make in $1"
    logcmd $MAKE $MAKE_JOBS -C $1 || \
        logerr "------ Make in $1 failed"
}

# Helper function that can be called by build scripts to install in a specific
# dir
make_install_in() {
    [[ -z $1 ]] && logerr "--- Make install in dir failed - no dir specified"
    logmsg "------ make install in $1"
    logcmd $MAKE -C $1 DESTDIR=${DESTDIR} install || \
        logerr "------ Make install in $1 failed"
}

build() {
    if [[ $BUILDARCH == "32" || $BUILDARCH == "both" ]]; then
        build32
    fi
    if [[ $BUILDARCH == "64" || $BUILDARCH == "both" ]]; then
        build64
    fi
}

build32() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 32-bit"
    export ISALIST="$ISAPART"
    make_clean
    configure32
    make_prog
    make_install
    popd > /dev/null
    unset ISALIST
    export ISALIST
}

build64() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 64-bit"
    make_clean
    configure64
    make_prog
    make_install
    popd > /dev/null
}

#############################################################################
# Build function for python programs
#############################################################################
# Note: The path to the python binary needs to be set in the $PYTHON variable
# you probably also need to add paths to the python libs in LDFLAGS depending
# on what you are bulding (-L and -R maybe required)
#############################################################################
python_build() {
    logmsg "Building using python setup.py"
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "--- setup.py build"
    LDFLAGS="$LDFLAGS" CFLAGS="$CFLAGS" logcmd $PYTHON ./setup.py build ||
        logerr "--- build failed"
    logmsg "--- setup.py install"
    LDFLAGS="$LDFLAGS" CFLAGS="$CFLAGS" logcmd $PYTHON \
        ./setup.py install --root=$DESTDIR ||
        logerr "--- install failed"
    popd > /dev/null
}


#############################################################################
# Build/test function for perl modules
#############################################################################
# Detects whether to use Build.PL or Makefile.PL
# Note: Build.PL probably needs Module::Build installed
#############################################################################
buildperl() {
    if [[ -f $SRCDIR/${PROG}-${VER}.env ]]; then
        logmsg "Sourcing environment file: $SRCDIR/${PROG}-${VER}.env"
        source $SRCDIR/${PROG}-${VER}.env
    fi
    if [[ $BUILDARCH == "32" || $BUILDARCH == "both" ]]; then
        buildperl32
    fi
    if [[ $BUILDARCH == "64" || $BUILDARCH == "both" ]]; then
        buildperl64
    fi
}

buildperl32() {
    if [[ -f $SRCDIR/${PROG}-${VER}.env32 ]]; then
        logmsg "Sourcing environment file: $SRCDIR/${PROG}-${VER}.env32"
        source $SRCDIR/${PROG}-${VER}.env32
    fi
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 32-bit"
    export ISALIST="$ISAPART"
    local OPTS
    OPTS=${MAKEFILE_OPTS//_ARCH_/}
    OPTS=${OPTS//_ARCHBIN_/$ISAPART}
    if [[ -f Makefile.PL ]]; then
        make_clean
        makefilepl32 $OPTS
        make_prog
        [[ -n $PERL_MAKE_TEST ]] && make_param test
        make_pure_install
    elif [[ -f Build.PL ]]; then
        build_clean
        buildpl32 $OPTS
        build_prog
        [[ -n $PERL_MAKE_TEST ]] && build_test
        build_install
    fi
    popd > /dev/null
    unset ISALIST
    export ISALIST
}

buildperl64() {
    if [[ -f $SRCDIR/${PROG}-${VER}.env64 ]]; then
        logmsg "Sourcing environment file: $SRCDIR/${PROG}-${VER}.env64"
        source $SRCDIR/${PROG}-${VER}.env64
    fi
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 64-bit"
    local OPTS
    OPTS=${MAKEFILE_OPTS//_ARCH_/$ISAPART64}
    OPTS=${OPTS//_ARCHBIN_/$ISAPART64}
    if [[ -f Makefile.PL ]]; then
        make_clean
        makefilepl64 $OPTS
        make_prog
        [[ -n $PERL_MAKE_TEST ]] && make_param test
        make_pure_install
    elif [[ -f Build.PL ]]; then
        build_clean
        buildpl64 $OPTS
        build_prog
        [[ -n $PERL_MAKE_TEST ]] && build_test
        build_install
    fi
    popd > /dev/null
}

makefilepl32() {
    logmsg "--- Makefile.PL 32-bit"
    logcmd $PERL32 Makefile.PL PREFIX=$PREFIX $@ ||
        logerr "Failed to run Makefile.PL"
}

makefilepl64() {
    logmsg "--- Makefile.PL 64-bit"
    logcmd $PERL64 Makefile.PL PREFIX=$PREFIX $@ ||
        logerr "Failed to run Makefile.PL"
}

buildpl32() {
    logmsg "--- Build.PL 32-bit"
    logcmd $PERL32 Build.PL prefix=$PREFIX $@ ||
        logerr "Failed to run Build.PL"
}

buildpl64() {
    logmsg "--- Build.PL 64-bit"
    logcmd $PERL64 Build.PL prefix=$PREFIX $@ ||
        logerr "Failed to run Build.PL"
}

build_clean() {
    logmsg "--- Build (dist)clean"
    logcmd ./Build distclean || \
    logcmd ./Build clean || \
        logmsg "--- *** WARNING *** make (dist)clean Failed"
}

build_prog() {
    logmsg "--- Build"
    logcmd ./Build ||
        logerr "Build failed"
}

build_test() {
    logmsg "--- Build test"
    logcmd ./Build test ||
        logerr "Build test failed"
}

build_install() {
    logmsg "--- Build install"
    logcmd ./Build pure_install --destdir=$DESTDIR || \
        logmsg "Build install failed"
}

test_if_core() {
    if [[ -z "$USEIPS" ]]; then
        logerr "Individual Perl module packages are IPS-only"
    fi
    logmsg "Testing whether $MODNAME is in core"
    logmsg "--- Ensuring ${PKGPREFIX}${PKG} is not installed"
    if logcmd pkg info ${PKGPREFIX}${PKG}; then
        logerr "------ Package ${PKGPREFIX}${PKG} appears to be installed.  Please uninstall it."
    else
        logmsg "------ Not installed, good." 
    fi
    if logcmd $PERL32 -M$MODNAME -e '1'; then
        # Module is in core, don't create a package
        logmsg "--- Module is in core for Perl $DEPVER.  Not creating a package."
        exit 0
    else
        logmsg "--- Module is not in core for Perl $DEPVER.  Continuing with build."
    fi
}

#############################################################################
# Clean up and print Done message
#############################################################################
clean_up() {
    logmsg "Cleaning up"
    if [[ -z $DONT_REMOVE_INSTALL_DIR ]]; then
        logmsg "--- Removing temporary install directory $DESTDIR"
        logcmd rm -rf $DESTDIR || \
            logerr "Failed to remove temporary install directory"
        logmsg "Done."
    fi
    if [[ -z "$USEIPS" ]]; then
        # Hack to dereference relative paths (/home/someone/../someoneelse/)
        REALOUTDIR=`cd $OUTDIR;echo $PWD`
        logmsg "If all went well, the package is now in $REALOUTDIR:"
        logmsg `ls -l $OUTDIR | grep $PKGFILE`
        if [[ -d /usr/include/openssl.omnibuild.safety ]]; then
            mv /usr/include/openssl.omnibuild.safety /usr/include/openssl
        fi
    fi
}

#############################################################################
# Helper function that will let you save a predefined function so you can
# override it and call it later
#############################################################################
save_function() {
    local ORIG_FUNC=$(declare -f $1)
    local NEWNAME_FUNC="$2${ORIG_FUNC#$1}"
    eval "$NEWNAME_FUNC"
}
