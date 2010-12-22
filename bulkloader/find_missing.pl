#!/usr/bin/env perl

%keys=();
open KEYS, "<$ARGV[0]" or die $!;
while (<KEYS>) {
    chomp;
    my ($k) = m|^(\d+)|;
    $keys{$k} = $_;
}
close KEYS;

%names=();
open NAMES, "<$ARGV[1]" or die $!;
while (<NAMES>) {
    chomp;
    my ($n) = m|^(.*)$|;
    #$n =~ s| |_|g;
    $names{$n} = $_;
    #print STDERR "$k\n";
}
close NAMES;

open DATA, "<$ARGV[2]" or die $!;
while (<DATA>) {
    if (my ($k,$n) = m|^(\d+)\t(.*?)\t|) {
	#print STDERR "$k,$n\n";
	$n =~ s|_| |g;
	if (!defined($keys{$k})) {
	    #print $k."\n";
	    print;
	}
    }
}
close DATA;
