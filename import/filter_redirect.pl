#!/usr/bin/env perl

#---------------------------------------------------

%page = ();
%rpage = ();
print STDERR "reading page names...\n";
open PAGE, "<./big_page.csv" or die $!;
for (<PAGE>) {
    chomp;
    if (my ($a,$b) = /^(\d+),0,(.*)$/) {
	$page{$a} = $b;
	if (defined($rpage{$b})) {
	    print STDERR "$b already defined?!\n";
	}
	$rpage{$b} = $a;
    }
}
close(PAGE);
print STDERR "  read ".(scalar keys %page)." pages...\n";
#---------------------------------------------------

%bigredirect = ();
print STDERR "reading bigredirect names...\n";
open BIGREDIRECT, "<./big_redirect.csv" or die $!;
for (<BIGREDIRECT>) {
    chomp;
    if (my ($a,$b) = /^(\d+),0,(.*)$/) {
	$bigredirect{$a} = $b;
    }
}
close(BIGREDIRECT);
print STDERR "  read ".(scalar keys %bigredirect)." redirects...\n";

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
	$b =~ s/(^'|'$)//g;
	$b =~ s|\\||g;
	$b =~ s|,|\\,|g;
	$redirect{$a}{lc $b} = 1;
	#$redirect{lc $b}{$a}=$b;
    }
}
close(SMALL);
print STDERR "  read ".(scalar keys %small)." small names...\n";

#---------------------------------------------------

$small_removed=0;
$redirect_moded=0;

%smallredirect = ();

print STDERR "hashing redirects...\n";

sub resolve {
    my ($id,$name,$depth) = @_;
    $depth++;
    if ($depth==10) {
	return undef;
    }
    if (defined($rpage{$name})) {
	my $rid = $rpage{$name};
	if ($id == $rid) {
	    return undef;
	}
        if (defined($bigredirect{$rid})) {
	    my $newrid = resolve($id,$bigredirect{$rid},$depth);
	    if ($newrid == $rid) {
		return undef;
	    }
	    $rid = $newrid;
	}
	return $rid;
    }
    return undef;
}

while ( my ($a, $b) = each(%bigredirect) ) {
    my $id = resolve($a,$b,0);
    if (defined($page{$a})) {
	if ($id != $rpage{$b}) {	
	    if (!defined($id)) {
		delete($bigredirect{$a});
	    } else {
		$bigredirect{$a} = $page{$id};
	    }
	}
    } else {
	delete($bigredirect{$a});
    }

    if (defined($page{$a}) && defined($small{$id})) {
	if (defined($small{$a})) {
	    delete($small{$a});		    
	    $small_removed++;
	} else {
	    my $p = lc $page{$a};
	    $p =~ s/(^'|'$)//g;
	    $p =~ s|\\||g;
	    $p =~ s|,|\\,|g;
	    $redirect{$id}{$p} = 1;
	    $smallredirect{$page{$a}} = $id;
	}
    }
}


# while ( my ($a, $b) = each(%bigredirect) ) {
#     my $id = resolve($a,$b,0);
#     if (defined($page{$a})) {
# 	if ($id != $rpage{$b}) {	
# 	    if (!defined($id)) {
# 		delete($bigredirect{$a});
# 	    } else {
# 		$bigredirect{$a} = $page{$id};
# 	    }
# 	}
#     } else {
# 	delete($bigredirect{$a});
#     }

#     if (defined($page{$a}) && defined($small{$id})) {
# 	$redirect{lc $page{$a}}{$id}=$page{$a};
# 	if (defined($small{$a})) {
# 	    delete($redirect{lc $small{$a}}{$a});
# 	    delete($small{$a});		    
# 	    $small_removed++;
# 	} else {
# 	    $smallredirect{$page{$a}} = $id;
# 	}
#     }
# }

#---------------------------------------------------

print STDERR "outputting redirects...\n";
for my $k (keys(%redirect)) {
    my @r = keys %{$redirect{$k}};
    print "$k,\"[".join(",",@r)."]\"\n";
}

# print STDERR "outputting redirects...\n";
# for my $k (keys(%redirect)) {
#     my @r = keys(%{$redirect{$k}});
#     print "$k,\"[".join(",",@r)."]\"\n";
#     if ($#r>0) {
# 	for my $p (@r) {
# 	    print "$redirect{$k}{$p},\"[$p]\"\n";
# 	}
#     }
# }

#---------------------------------------------------

print STDERR "writing smallredirect...\n";
open SMALLREDIRECT, ">./small_redirect.csv" or die $!;
for my $k (keys(%smallredirect)) {
    print SMALLREDIRECT "$k,$smallredirect{$k}\n";
}
close(SMALLREDIRECT);

#---------------------------------------------------

if ($small_removed>0) {
    print STDERR "rewriting small names, $small_removed removed...\n";
    open SMALL, ">./small_page.csv" or die $!;
    foreach my $k (keys(%small)) {
	print SMALL "$k,$small{$k}\n";
    }
    close(SMALL);
}
