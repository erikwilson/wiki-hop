if [ ! -f pagelinks.csv ]; then
echo "unpacking pagelinks.csv..."
time zcat enwiki-latest-pagelinks.sql.gz | \
     ./sql2csv.pl | \
     ./filter_page.pl >pagelinks.csv
fi
time ./filter_templatepagelinks.pl <pagelinks.csv >./templatepagelinks.csv
time ./filter_ignorepagelinks.pl <pagelinks.csv >./ignorepagelinks.csv
time ./filter_pagelinks.pl <pagelinks.csv >./goodpagelinks.csv
time ./filter_fromlinks.pl >./fromlinks.csv
time ./filter_redirect.pl >./redirect.csv
