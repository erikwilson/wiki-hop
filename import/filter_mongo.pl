#!/usr/bin/env perl

use strict;

#---------------------------------------------------

my %small = ();
print STDERR "reading small names...\n";
open SMALL, "<:encoding(utf8)", "./small_page.csv" or die $!;
for (<SMALL>) {
    chomp;
    if (my ($a,$b) = /^(\d+),'(.*)'$/) {
	$b =~ s|\\||g;
	$b =~ s|'|\\'|g;
	$small{$a} = $b;
    }
}
close(SMALL);
print STDERR "  read ".(scalar keys %small)." small names...\n";

#---------------------------------------------------

my %links = ();
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

my %from = ();
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

my %redirect = ();
print STDERR "reading redirect names...\n";
open REDIRECT, "<:encoding(utf8)", "./redirect.csv" or die $!;
for (<REDIRECT>) {
    if (my ($a,$b) = /^(\d+),"\[(.*)\]"$/) {
	$b =~ s|_| |g;
	$b =~ s|'|\\'|g;
	$redirect{$a}=join("','",split(/(?<!\\),/,$b));
    }
}
close(REDIRECT);

print STDERR "   read ".(scalar keys %redirect)." redirect entries\n";

#---------------------------------------------------

print STDERR "writing mongo data...\n";
open LINKSJSON,  ">:encoding(utf8)", "./mongo_links.json" or die $!;
open ORACLEJSON, ">:encoding(utf8)", "./mongo_oracle.json" or die $!;
open ALIASJSON,  ">:encoding(utf8)", "./mongo_alias.json" or die $!;
open METAJSON,   ">:encoding(utf8)", "./mongo_meta.json" or die $!;

for my $k (sort {$a <=> $b} keys %small) {
    my $name = lc $small{$k};
    $name =~ s|[\P{IsWord}]+|_|g;
    my %words = ();
    for my $w (split(/_/,$name)) {
	$words{$w}=1 if length($w)>2;
    }
    $name = $small{$k};
    $name =~ s|\\||g;
    $name =~ s|'|\\'|g;
    $name =~ s|_| |g;
    $words{lc $name} = 1;

    my $oracle = join("','",keys %words);
    my $sizeTo = scalar(split(',',$links{$k}));
    my $sizeFrom = scalar(split(',',$from{$k}));

    print LINKSJSON  "{_id:$k,t:[$links{$k}],f:[$from{$k}]}\n";
    print ORACLEJSON "{_id:'$name',w:['$oracle'],p:$sizeFrom}\n";
    print ALIASJSON  "{_id:$k,a:['$redirect{$k}']}\n";
    print METAJSON   "{_id:$k,n:'$small{$k}',t:$sizeTo,f:$sizeFrom}\n";
}
close (LINKSTAB);
