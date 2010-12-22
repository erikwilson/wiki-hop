#!/usr/bin/env perl

#---------------------------------------------------

%small = ();
%rsmall = ();
print STDERR "reading small names...\n";
open SMALL, "<./small_page.csv" or die $!;
for (<SMALL>) {
    if (my ($a,$b) = /^(\d+),(.*)$/) {
	$small{$a} = $b;
	$rsmall{$b} = $a;
    }
}
close(SMALL);
print STDERR "   read ".(scalar keys %small)."/".(scalar keys %rsmall)." page entries\n";

#---------------------------------------------------

%ignore = ();
%getlinks = ();
print STDERR "reading ignore names...\n";
open IGNORE, "<./ignorepagelinks.csv" or die $!;
for (<IGNORE>) {
    if (my ($a,$b) = /^(\d+),"\[(.*)\]"$/) {
	my @c = split(",",$b);
	push(@{$ignore{$a}},@c);
    }
}
close(IGNORE);
print STDERR "   read ".(scalar keys %ignore)." ignore entries\n";

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

print STDERR "injesting pagelinks...\n";
{
    my ($last,@array);

    sub printEntry {
	if (defined($last) and $#array>=0) {
	    print "$last,\"[".join(",",@array)."]\"\n";
	}
    }

    while (<>) {
	if (my ($a,$b) = /^(\d+),0,('.*?(?<!\\)')$/) {
	    if (defined($small{$a}) && (defined($rsmall{$b})||defined($redirect{$b}))) {

		if ($a != $last) {
		    printEntry();
		    $last = $a;
		    @array = ();
		}

		my $id = (defined($rsmall{$b})?$rsmall{$b}:$redirect{$b});

		my @g = grep {$_==$id} @{$ignore{$a}};

		if ($#g<0) {
		    push(@array,$id);
		}
	    }
	}
    }

    printEntry();
}
