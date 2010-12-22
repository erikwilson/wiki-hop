#!/usr/bin/env perl

#---------------------------------------------------

%page = ();
print STDERR "reading page names...\n";
open PAGE, "<./big_page.csv" or die $!;
for (<PAGE>) {
    chomp;
    if (my ($a,$b) = /^(\d+),0,(.*)$/) {
	$page{$a} = $b;
    }
}
close(PAGE);

#---------------------------------------------------

%small = ();
%rsmall = ();
%redirect = ();
print STDERR "reading small names...\n";
open SMALL, "<./small_page.csv" or die $!;
for (<SMALL>) {
    chomp;
    if (my ($a,$b) = /^(\d+),(.*)$/) {
	$small{$a} = $b;
	$rsmall{$b} = $a;
	$redirect{lc $b}{$a}=$b;
    }
}
close(SMALL);

#---------------------------------------------------

$removed=0;

print STDERR "hashing redirects...\n";
my ($last,$id,$pn,$a,$b,$n);

while (<>) {
    chomp;
    if (($a,$b) = /^(\d+),0,(.*)$/) {
	if (defined($rsmall{$b}) && defined($page{$a})) {		
	    $redirect{lc $page{$a}}{$rsmall{$b}}=$page{$a};
	    if (defined($small{$a})) {
		print STDERR "Removing $page{$a} redirect from small...\n";
		delete($redirect{lc $small{$a}}{$a});
		delete($small{$a});		    
		$removed++;
	    }
	}
    }
}

#---------------------------------------------------

print STDERR "outputting redirects...\n";
for my $k (keys(%redirect)) {
    my @r = keys(%{$redirect{$k}});
    print "$k,\"[".join(",",@r)."]\"\n";
    if ($#r>0) {
	for my $p (@r) {
	    print "$redirect{$k}{$p},\"[$p]\"\n";
	}
    }
}

#---------------------------------------------------

if ($removed>0) {
    print STDERR "rewriting small names, $removed removed...\n";
    open SMALL, ">./small_page.csv" or die $!;
    foreach my $k (keys(%small)) {
	print SMALL "$k,$small{$k}\n";
    }
    close(SMALL);
}
