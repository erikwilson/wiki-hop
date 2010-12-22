#!/usr/bin/env perl

#---------------------------------------------------

%redirect = ();
print STDERR "reading redirect names...\n";
open REDIRECT, "<./small_redirect.csv" or die $!;
for (<REDIRECT>) {
    if (my ($a,$b) = /^('.*?(?<!\\)'),(\d+)$/) {
	$redirect{$a}=$b;
    }
}
close(REDIRECT);
print STDERR "   read ".(scalar keys %redirect)." redirect entries\n";

#---------------------------------------------------

%rsmall = ();
print STDERR "reading small names...\n";
open SMALL, "<./small_page.csv" or die $!;
for (<SMALL>) {
    if (my ($a,$b) = /^(\d+),('.*?(?<!\\)')$/) {
	$rsmall{$b}=$a;
    }
}
close(SMALL);
print STDERR "   read ".(scalar keys %rsmall)." small entries\n";

#---------------------------------------------------

%template = ();
%getlinks = ();
print STDERR "reading template names...\n";
open TEMPLATE, "<./templatepagelinks.csv" or die $!;
for (<TEMPLATE>) {
    if (my ($a,$b) = /^(\d+),"\[(.*)\]"$/) {
	my @c = split(",",$b);
	push(@{$template{$a}},@c);
	for my $l (@c) {
	    $getlinks{$l}=1;
	}
    }
}
close(TEMPLATE);
print STDERR "   read ".(scalar keys %template)." template entries\n";
print STDERR "   found ".(scalar keys %getlinks)." target pages\n";

#---------------------------------------------------

%links = ();
print STDERR "injesting pagelinks...\n";
while (<>) {
    if (my ($a,$b) = /^(\d+),0,(.*)$/) {
	if (defined($getlinks{$a})) {
	    if (defined($rsmall{$b}) || defined($redirect{$b})) {
		my $n = (defined($rsmall{$b})?$rsmall{$b}:$redirect{$b});
		$links{$a}{$n}=1;
	    }
	}
    }
}
print STDERR "   filled ".(scalar keys %links)." links\n";

#---------------------------------------------------

print STDERR "writing pagelinks to ignore...\n";
for my $k (keys(%template)) {
    my %h = ();
    for my $t (@{$template{$k}}) {	
	for my $v (keys(%{$links{$t}})) {
	    $h{$v}=1;
	}
    }
    if (scalar keys %h) {
	print "$k,\"[".join(",",keys(%h))."]\"\n";
    }
}
