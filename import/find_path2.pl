#!/usr/bin/env perl

my $seed = 1;
my $mindepth = 3;
my $maxlinks = 1000;
my $alwaysmax = 1;
my $trimmed = 0;
srand($seed);

print "looking for path from $ARGV[0] to $ARGV[1]\n";

#------------------------------------------------------------

print "loading small pages file...\n";
%page = {};
%name = {};
open PAGE, "<./small_page.csv" or die $!;
for (<PAGE>) {
    my ($a,$b) = /^(\d+),(.*)$/;
    $page{$b} = $a;
    $name{$a} = $b;
}
close(PAGE);

#------------------------------------------------------------

%redirect = ();
print STDERR "reading redirect names...\n";
open REDIRECT, "<./redirect.csv" or die $!;
for (<REDIRECT>) {
    if (my ($a,$b) = /^('.*?(?<!\\)'),"\[(.*)\]"$/) {
	my @c = split(",",$b);
	push(@{$redirect{$a}},@c);
    }
}
close(REDIRECT);
print STDERR "   read ".(scalar keys %redirect)." redirect entries\n";

#------------------------------------------------------------

print "loading links file...\n";
%links = {};
open PAGELINKS, "<./goodpagelinks.csv" or die $!;
for (<PAGELINKS>) {
    my ($a,$b) = /^(\d+),"\[(.*)\]"$/;
    my @arr = ();
    @arr = split(",",$b);
    $links{$a} = [@arr];
}
close(PAGELINKS);

#------------------------------------------------------------

my (%path,%level,%next,%nodeCount);

# fisher_yates_
sub shuffle {
    my $array = shift;
    my $i;
    for ($i = @$array; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @$array[$i,$j] = @$array[$j,$i];
    }
}


sub populate {
    my ($d,$id) = @_;
    my @l = @{$links{$id}};
    my $a = scalar keys %$d;
    for my $n (@l) { $d->{$n}=$id if (!defined($d->{$n}) && !defined($path{$n})); }
    my $b = scalar keys %$d;	
    $nodeCount{$id}+=$b-$a;
}

sub decNodeCount {
    my ($i) = @_;
    if (defined($nodeCount{$i})) {
	--$nodeCount{$i};
	if ($nodeCount{$i}<=0) {
	    my $nid = $path{$i};
	    $trimmed++;
	    delete($path{$i});
	    delete($nodeCount{$i});
	    decNodeCount($nid);	    
	}
    } else {
	print STDERR "asked to delete a nodeCount which isn't defined $i!\n" if (defined($i));
    }
}

sub find {
    my ($pageA,$pageB) = @_;
    my $depth = 0;
    my $found = 0;

    %path = ();
    %level = ();
    %next = ();
    %nodeCount = ();
    
    $path{$pageA} = 0;
    populate(\%level,$pageA);

    while (!$found && scalar keys %level) {
	my @k = sort {$a cmp $b} keys %level;
	shuffle(\@k) if ($seed);
	my @r;
	my @k2;

	if ($mindepth <= $depth) { 
	    @r = grep {$_==$pageB} @k
	} 
	if ($#r>=0) {
	    $path{$pageB} = $level{$pageB};
	    $found = 1;
	} else {
	    if ($maxlinks && ($alwaysmax || $mindepth>$depth) && $#k>=$maxlinks) {
		@k2 = @k[$maxlinks .. $#k];
		@k = @k[0 .. $maxlinks-1];
	    }
	    for my $i (@k) {
		if (!defined($path{$i}) && $i!=$pageB) {
		    $path{$i} = $level{$i};
		    populate(\%next,$i);
		} else {
		    push(@k2,$i);
		}
	    }
	    for my $i (@k2) {
		decNodeCount($level{$i});
	    }

	    if ($depth>=20) {
		print STDERR "Aborting at depth $depth!\n";
		%next=();
	    }

	    %level = %next;
	    %next = ();
	    $depth++;
	}
    }

    my $nodesize = scalar keys %path;
    print STDERR "Done with $nodesize NODES!\n";

    if ($found) {
	print STDERR "FOUND A CONNECTION IN $nodesize NODES!\n";
	my (@p,$id);
	$id = $pageB;
	while ($id!=0) {
	    push(@p,$name{$id});
	    $id = $path{$id};
	}

	print STDERR join(" -> ",reverse @p)."\n";
    } else {
	print STDERR "Connection not found!\n";
    }
}


#------------------------------------------------------------


print "\nReady: ";

while (<>) {
    chomp;
    $trimmed = 0;

    if (m/^seed\s*=\s*(\d+)\s*$/i) {
	$seed = $1;
	print STDERR "Seed changed to $seed!\n";
    } elsif (m/^mindepth\s*=\s*(-?)(\d+)\s*$/i) {
	if ($1 eq "-") {
	    $alwaysmax=1;
	} else {
	    $alwaysmax=0;
	}
	$mindepth = $2;
	print STDERR "Min depth changed to $mindepth!\n";
    } elsif (m/^maxlinks\s*=\s*(-?\d+)\s*$/i) {
	$maxlinks = $1;
	print STDERR "Max links changed to $maxlinks!\n";
    } elsif (my ($nameA,$nameB) = m/^([^,]*)(?<!\\),([^,]*)$/) {

	if (defined($redirect{"'$nameA'"})) { $pageA = $redirect{"'$nameA'"}[0]; } 
	else { $pageA = $redirect{lc "'$nameA'"}[0]; }
	
	if (defined($redirect{"'$nameB'"})) { $pageB = $redirect{"'$nameB'"}[0]; }
	else { $pageB = $redirect{lc "'$nameB'"}[0]; }
	
	print STDERR "NOT " if (!defined($pageA) || !defined($pageB));
	print STDERR "looking for path from $nameA($pageA) to $nameB($pageB) with seed $seed, mindepth $mindepth, maxlinks $maxlinks\n";

	srand($seed);
	find($pageA,$pageB) if (defined($pageA) && defined($pageB));
	print STDERR "\nTrimmed $trimmed nodes during that search!\n";

    } else {
	print STDERR "Unknown command!\n";
    }

    print STDERR "\nReady: ";
}
