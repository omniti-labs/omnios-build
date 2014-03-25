# Package server URL and publisher
PKGPUBLISHER=omnios
PKGSRVR=http://pkg-il-1.int.omniti.net:10006/

# Uncommenting this line will create a on-disk repo in
# the top level of your checkout and publish there instead
# of the URI specified above.
#
#PKGSRVR=file:///$MYDIR/../tmp.repo/

# These two should be uncommented and set to specific git changeset IDs
# if illumos-kvm and illumos-kvm-cmd get too far ahead of illumos-{gate,omnios}.
#KVM_ROLLBACK=a8ea37e8deb99265682c66c23f787f704e77fb91
#KVM_CMD_ROLLBACK=1c6181be55d1cadc4426069960688307a6083131
