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
my $tmpdir = shift;
my $destdir = shift;
open(A, "$tmpdir/perl.32.bit");
while(<A>) {
    chomp;
    if(/\/man\// || /\.pod$/) { $docs{$_}++; }
    else {$a{$_}++;}
}
close(A);

open(A, "<$tmpdir/perl.all.bit");
while(<A>) {
    chomp;
    $b{$_}++ unless (exists $a{$_} || exists $docs{$_});
}
close(A);

sub mog {
    my $h = shift;
    my $f = shift;
    open(A, ">$f");
    foreach (keys %$h) {
        my $ondisk = "$destdir/$_";
        my $t = 'file' if -f $ondisk;
        $t = 'dir' if -d $ondisk;
        $t = 'link' if -l $ondisk;
        print A "<transform $t path=^$_\$ -> drop>\n";
        if($t eq 'file') {
            print A "<transform hardlink path=^$_\$ -> drop>\n";
        }
    }
    close(A);
}

mog(\%docs, "$tmpdir/nodocs.mog");
mog(\%a, "$tmpdir/no32.mog");
mog(\%b, "$tmpdir/no64.mog");
