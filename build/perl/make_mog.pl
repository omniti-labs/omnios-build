
my $tmpdir = shift;
my $destdir = shift;
open(A, "$tmpdir/perl.32.bit");
while(<A>) {
    chomp;
    if(/\/man\// || /pod/) { $docs{$_}++; }
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
