#!/usr/bin/env perl

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

sub find {
    my ($pageA,$pageB) = @_;
    my $found = 0;
    my @index;
    my @arrays;
    my $depth = 0;
    my $current = $pageA;
    my @path;
    my $abort = 1;
    my $depth_abort = 0;

    $index[0] = 0;
    $path[0] = ( $pageA );
    $arrays[0][0] = $links{$current};
    $pathIndex[0] = ();
    %visited = {};

    while (!$found && !$depth_abort) {
	my @nodes = @{$arrays[$depth][$index[$depth]]};
	if (!defined($path[$depth+1])) {
	    $path[$depth+1] = ();
	}
	if (!defined($arrays[$depth+1])) {
	    $arrays[$depth+1] = ();
	}
	if (!defined($pathIndex[$depth+1])) {
	    $pathIndex[$depth+1] = ();
	}

	#print "Works on array # $index[$depth] $path[$depth][$index[$depth]] $name{$path[$depth][$index[$depth]]}\n";
	#print "Parent is $pathIndex[$depth][$index[$depth]]\n";

	for my $i (0 .. $#nodes) {
	    if (!$visited{$nodes[$i]}) {
		#print "Checking $depth $i $nodes[$i] $name{$nodes[$i]}\n";
		$visited{$nodes[$i]} = 1;
		$abort = 0;
		push @{$path[$depth+1]}, $nodes[$i];
		push @{$pathIndex[$depth+1]}, $index[$depth];
		push @{$arrays[$depth+1]}, $links{$nodes[$i]};

		if ($nodes[$i] == $pageB) {
		    $found = 1;
		    last;
		}	    
	    }
	}

	if (!$found) {
	    if ($index[$depth] == $#{$arrays[$depth]}) {
		if ($abort) {
		    $depth_abort = 1;
		} else {
		    $depth++;
		    $index[$depth] = 0;
		    print "Going to depth $depth!\n";
		}
	    } else {
		$abort = 1;
		$index[$depth]++;
	    }
	}
    }


    if ($found) {

	print "FOUND A CONNECTION!\n";

	my @mypath;
	push @mypath, $name{$pageB};

	my $last = $index[$depth];

	for my $i (reverse 1 .. $depth) {	
	    push @mypath, $name{$path[$i][$last]};
	    $last = $pathIndex[$i][$last];
	}
	push @mypath, $name{$pageA};

	print join(" -> ",reverse @mypath)."\n";
    } else {
	print "Connection not found!\n";
    }
}

print "\nReady: ";
while (<>) {
    chomp;
    my ($nameA,$nameB) = split(",");
    my ($pageA,$pageB) = ($redirect{lc $nameA}[0],$redirect{lc $nameB}[0]);
    print "NOT " if (!defined($pageA) || !defined($pageB));
    print "looking for path from $nameA($pageA) to $nameB($pageB)\n";
    find($pageA,$pageB) if (defined($pageA) && defined($pageB));
    print "\nReady: ";
}
