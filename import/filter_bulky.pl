#!/usr/bin/env perl


#---------------------------------------------------

%small = ();
print STDERR "reading small names...\n";
open SMALL, "<:encoding(utf8)", "./small_page.csv" or die $!;
for (<SMALL>) {
    chomp;
    if (my ($a,$b) = /^(\d+),'(.*)'$/) {
	$b =~ s|\\||g;
#	$b =~ s|'|\\'|g;
	$small{$a} = $b;
    }
}
close(SMALL);
print STDERR "  read ".(scalar keys %small)." small names...\n";

#---------------------------------------------------

%links = ();
print STDERR "reading links names...\n";
open LINKS, "<:encoding(utf8)", "./goodpagelinks.csv" or die $!;
for (<LINKS>) {
    if (my ($a,$b) = /^(\d+),"\[(.*)\]"$/) {
	$links{$a} = $b;
    }
}
close(LINKS);

print STDERR "   read ".(scalar keys %links)." link entries\n";

#---------------------------------------------------

%from = ();
print STDERR "reading from names...\n";
open FROM, "<:encoding(utf8)", "./fromlinks.csv" or die $!;
for (<FROM>) {
    if (my ($a,$b) = /^(\d+),"\[(.*)\]"$/) {
	$from{$a} = $b;
    }
}
close(FROM);

print STDERR "   read ".(scalar keys %from)." from entries\n";

#---------------------------------------------------

%redirect = ();
print STDERR "reading redirect names...\n";
open REDIRECT, "<:encoding(utf8)", "./redirect.csv" or die $!;
for (<REDIRECT>) {
    if (my ($a,$b) = /^(\d+),"\[(.*)\]"$/) {
	$b =~ s|_| |g;
#	$b =~ s|'|\\'|g;
	$redirect{$a}=$b;
    }
}
close(REDIRECT);

print STDERR "   read ".(scalar keys %redirect)." redirect entries\n";

#---------------------------------------------------

print STDERR "writing bulky data...\n";
open LINKSTAB, ">:encoding(utf8)", "./gae_data.tab" or die $!;

for my $k (sort {$a <=> $b} keys %small) {
    my $name = lc $small{$k};
    $name =~ s|[\P{IsWord}]+|_|g;
    my %words = ();
    for my $w (split(/_/,$name)) {
	$words{$w}=1 if length($w)>2;
    }
    $name = lc $small{$k};
    $name =~ s|\\||g;
#    $name =~ s|'|\\'|g;
    $name =~ s|,|\\,|g;
    $name =~ s|_| |g;
    $words{$name} = 1;
    
    print LINKSTAB "$k\t$small{$k}\t$links{$k}\t$from{$k}\t$redirect{$k}\t".join(",",keys %words)."\n";
}
close (LINKSTAB);
