#!/usr/bin/env perl

#---------------------------------------------------

%page = ();
print STDERR "reading page names...\n";
open PAGE, "<./big_page.csv" or die $!;
for (<PAGE>) {
    if (my ($a,$b) = /^(\d+),0,(.*)$/) {
	$page{$a} = $b;
    }
}
close(PAGE);

#---------------------------------------------------

# $CATEGORY = 
#     "(_birth|_death|_album|_single|_music_groups|_film|_novel|_book|television_|".
#     "_historical|_document|_resolution|_treaties|_in_law|_god|_companies|companies_)";

# $NOT_CATEGORY =
#     "(_awards'|_ceremonies'|_film_award'|_stubs'|television_(network|channel|news)|".
#     "news_channel|european_broadcasting_union_members|publishing_compan|compilation_albums|".
#     "_lists'|'lists_of_|'years_in_|'days_of_|'submissions_for_)";

# $NOT_TITLE =
#     "((^'(list_of|[a-z]+_awards?_))|(_award_for_best_)|((_awards?)'\$))";


$PEOPLE = "'(?:\\d+s?_(?:ad_|bc_)?(?:births|deaths)|living_people)'";
$FICTIONAL = "'(?:holiday|christmas)_characters'";
$DEITIES = "(?:'deities|deities')";
$MUSIC = "'(?:\\d{4,4}s_music_groups|musical_groups_established_in_\\d{4,4})'";
$CATEGORY = "(?:$PEOPLE|$FICTIONAL|$DEITIES|$MUSIC)";
$NOT_CATEGORY = "_stubs'";
$NOT_TITLE = "'list_of_";

print STDERR "outputting pages which match categories...\n";
{
    my ($last,@array,$id,$pn,$a,$b,$n);

    sub printEntry {
	if (defined($last) && scalar(@array)>=5) {
	    my $cat = lc join(",",@array);
	    if ($cat =~ m/${CATEGORY}/ && $cat !~ m/${NOT_CATEGORY}/) {
		print "$last,$page{$last}\n";
	    }
	}
    }
    
    while (<>) {
	($a,$b) = /^(\d+),('.*?(?<!\\)'),/;

	if ($a != $last) {
	    printEntry();
	    $last = $a;
	    @array = ();
	}

	if (defined($page{$a}) && (lc $page{$a}) !~ m/${NOT_TITLE}/) {
	    push(@array,$b);
	}
    }
    
    printEntry();
}
