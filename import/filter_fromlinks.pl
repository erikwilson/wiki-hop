#!/usr/bin/env perl

#---------------------------------------------------

%from = ();
%links = ();
print STDERR "reading good names...\n";
open GOOD, "<./goodpagelinks.csv" or die $!;
for (<GOOD>) {
    if (my ($a,$b) = /^(\d+),"\[(.*)\]"$/) {
	my @c = split(",",$b);
	for my $to (@c) {
	    push(@{$from{$to}},$a);
	    $links{$a} = 1;
	}
    }
}
close(GOOD);

print STDERR "   read ".(scalar keys %from)."/".(scalar keys %links)." link entries\n";

#---------------------------------------------------

%small = ();
print STDERR "reading small names...\n";
open SMALL, "<./small_page.csv" or die $!;
for (<SMALL>) {
    chomp;
    if (my ($a,$b) = /^(\d+),(.*)$/) {
	$small{$a} = $b;
    }
}
close(SMALL);
print STDERR "  read ".(scalar keys %small)." small names...\n";

#---------------------------------------------------

print STDERR "writing fromlinks...\n";
{
    for my $key (keys %from) {
	print "$key,\"[".join(",",@{$from{$key}})."]\"\n";
    }
}

my $small_removed = 0;

for my $key (keys %small) {
    if (!defined($links{$key}) && !defined($from{$key})) {
	delete($small{$key});
	$small_removed++;
    }
}

#---------------------------------------------------

if ($small_removed>0) {
    print STDERR "rewriting small names, $small_removed removed...\n";
    open SMALL, ">./small_page.csv" or die $!;
    for my $k (keys %small) {
	print SMALL "$k,$small{$k}\n";
    }
    close(SMALL);
}
