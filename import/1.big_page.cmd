if [ ! -f ./big_page.csv ]; then
echo "unpacking big_page.csv..."

time zcat enwiki-latest-page.sql.gz | \
     ./sql2csv.pl | \
     ./filter_page.pl >./big_page.csv

fi
