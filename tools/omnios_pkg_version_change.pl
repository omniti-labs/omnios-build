#!/usr/bin/perl
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#

#
# Copyright 2013 OmniTI Computer Consulting, Inc.  All rights reserved.
#

=head1 NAME

omnios_pkg_version_change.pl - Generate a list of package changes between two OmniOS releases.

=head1 SYNOPSIS

  ./omnios_pkg_version_change.pl [-h] -p <previous> -n <new> -f <input file>

=head1 DESCRIPTION

This utility reads a file containing the output of C<pkg list -Hfav> and determines
the package changes between two releases. It then prints a summary of changes in a
format suitable for pasting into the release notes wiki page.

=head2 Command Line Options

=over

=item --help / -h

Display a list of options.

=item --previous / -p

The previous release that is the starting point for comparison. Expressed as a
"nickname", or shortened form of the release, e.g. "006" for r151006.

=item --new / -n

The new release for which one wants to display the changes.  Expressed as a
"nickname", or shortened form of the release, e.g. "008" for r151008.

=item --file / -f

Input file from which the package FMRIs are read. It should contain the output
of C<pkg list -Hfav> on a system that can see both the previous release's
packages as well as the new.

=back

=cut

use warnings;
use strict;
use Getopt::Long;

my ($previous_release, $new_release, $input_file, $help) = (0,0,'',0);

GetOptions(
  "p|prev=i"  => \$previous_release,
  "n|new=i"   => \$new_release,
  "f|file=s"  => \$input_file,
  "h|help"    => sub { $help++ }
);

if ( ! $previous_release || ! $new_release || ! $input_file || $help ) {
  print "Options:\n";
  print "\t-p|--prev  Previous release nickname (006, 06, 6)\n";
  print "\t-n|--new   New release nickname (008, 08, 8)\n";
  print "\t-f|--file  Input file name\n";
  print "\t-h|--help  This output\n";
  exit 0;
}

$previous_release = "151" . sprintf("%03d", $previous_release);
$new_release      = "151" . sprintf("%03d", $new_release);

my $regex = "5.11-0.($previous_release|$new_release)";

my %versions = ();

open IN,"<$input_file"
  or die "Failed to open file $input_file: $!\n";
while (<IN>) {
  my $line = $_;
  if ( $line =~ /$regex/ ) {
    my $omnios_ver = $1;
    $line =~ /^pkg:\/\/[^\/]+\/([^\@]+)\@([^\s]+)/;
    my ($pkg,$ver) = ($1,$2);
    my ($comp_ver,$other) = split(/,/,$ver);

    if ( ! $versions{$pkg} || ! $versions{$pkg}{$omnios_ver} ) {
      $versions{$pkg}{$omnios_ver} = $comp_ver;
    }
  }
}
close IN;

print " * Package changes ([+] Added, [-] Removed, [*] Changed)\n";

foreach my $pkg ( sort keys %versions ) {
  if ( $versions{$pkg}{$previous_release} && ! $versions{$pkg}{$new_release} ) {
    print "   * [-] $pkg\n";
  }
  elsif ( ! $versions{$pkg}{$previous_release} && $versions{$pkg}{$new_release} ) {
    print "   * [+] $pkg $versions{$pkg}{$new_release}\n";
  }
  elsif ( $versions{$pkg}{$previous_release} ne $versions{$pkg}{$new_release} ) {
    print "   * [*] $pkg $versions{$pkg}{$previous_release} -> $versions{$pkg}{$new_release}\n";
  }
}
