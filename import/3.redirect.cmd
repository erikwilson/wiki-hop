if [ ! -f ./big_redirect.csv ]; then
echo "unpacking big_redirect.csv..."
time zcat enwiki-latest-redirect.sql.gz | \
     ./sql2csv.pl | \
     ./filter_page.pl >./big_redirect.csv
fi

time ./filter_redirect.pl >./redirect.csv
