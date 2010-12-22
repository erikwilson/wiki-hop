time zcat enwiki-latest-categorylinks.sql.gz | \
     ./sql2csv.pl | \
     ./filter_categorylinks.pl >./small_page.csv
