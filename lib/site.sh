# Package server URL and publisher
: ${PKGPUBLISHER=ms.omniti.com}
: ${PKGSRVR=http://pkg-il-1.int.omniti.net:10007/}

# To create a on-disk repo in the top level of your checkout
# and publish there instead of the URI specified above.
#
PKGSRVR=file:///$MYDIR/../tmp.repo/

export PATH=$PATH:/opt/omni/bin

PREFIX=/opt/omni
reset_configure_opts
