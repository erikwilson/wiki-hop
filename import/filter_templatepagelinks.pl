#!/usr/bin/env perl

#---------------------------------------------------

%page = ();
%rpage = ();
print STDERR "reading page names...\n";
open PAGE, "<./big_page.csv" or die $!;
for (<PAGE>) {
    if (my ($a,$b) = /^(\d+),10,(.*)$/) {
	$rpage{$b} = $a;
    }
}
close(PAGE);

#---------------------------------------------------

%tmpredirect = ();
print STDERR "reading bigredirect names...\n";
open BIGREDIRECT, "<./big_redirect.csv" or die $!;
for (<BIGREDIRECT>) {
    if (my ($a,$b) = /^(\d+),10,(.*)$/) {
	$tmpredirect{$a} = $b;
    }
}
close(BIGREDIRECT);

#---------------------------------------------------

%small = ();
print STDERR "reading small names...\n";
open SMALL, "<./small_page.csv" or die $!;
for (<SMALL>) {
    if (my ($a,$b) = /^(\d+),(.*)$/) {
	$small{$a} = $b;
    }
}
close(SMALL);

#---------------------------------------------------


sub resolve {
    my ($hash,$id,$name,$depth) = @_;
    $depth++;
    if ($depth==10) {
	return undef;
    }
    if (defined($rpage{$name})) {
	my $rid = $rpage{$name};
	if ($id == $rid) {
	    return undef;
	}
        if (defined($hash->{$rid})) {
	    my $newrid = resolve($hash,$id,$hash->{$rid},$depth);
	    if ($newrid == $rid) {
		return undef;
	    }
	    $rid = $newrid;
	}
	return $rid;
    }
    return undef;
}


print STDERR "outputting pagelinks in template category...\n";
{
    my ($last,%entry);

    sub printEntry {
	if (defined($last) and (scalar keys %entry)>0) {
	    print "$last,\"[".join(",",keys %entry)."]\"\n";
	}
    }

    while (<>) {

	if (my ($a,$b) = /^(\d+),10,('.*?(?<!\\)')$/) {
	    if (defined($small{$a})) {
		if ($a != $last) {
		    printEntry();
		    $last = $a;
		    %entry = ();
		}

		if (defined($rpage{$b})) {
		    my $id = $rpage{$b};
		    my $oid = $id;
		    if (defined($tmpredirect{$id})) {
			$id = resolve(\%tmpredirect,$id,$tmpredirect{$id},0);
			if (!defined($id) || $oid == $id) {
			    delete($tmpredirect{$oid});
			}
		    }
		    if ($oid!=$id) {
			$rpage{$b}=$id;
		    }
		    if (defined($id)) {
			$entry{$id}=1;
		    }
		}
	    }
	}
    }
    
    printEntry();
}
