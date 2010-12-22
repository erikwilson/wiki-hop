#!/usr/bin/env perl

%orig = ();
print STDERR "reading orig names...\n";
open ORIG, "<$ARGV[0]" or die $!;
for (<ORIG>) {
    my ($id) = m|^(\d+)\t|;
    $orig{$id} = $_;
}

print STDERR "reading new names...\n";
open NEW, "<$ARGV[1]" or die $!;
for (<NEW>) {
    my ($id) = m|^(\d+)\t|;
    if (!defined($orig{$id}) || $orig{$id} ne $_) {
	print $_;
    }
}
