#!/usr/bin/env perl

%redirected = {};

open REDIRECT, "<redirect.txt" or die $!;
while (<REDIRECT>) {
    my ($p,$r) = /^(\d+)\t(.*)$/;
    $redirected{$p} = $r;
}
close(REDIRECT);

open PAGE, "<page.txt" or die $!;
while (<PAGE>) {
    my ($p) = /^(\d+)\t/;
    if (!defined($redirected{$p})) {
	print;
    }
}
close(PAGE);
