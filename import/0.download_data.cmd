function fetch {
    if [ ! -f $1 ]; then
	echo Fetching $1
	curl http://dumps.wikimedia.org/enwiki/latest/$1 -o $1
    else
	echo $1 already exists
    fi
}

fetch enwiki-latest-page.sql.gz
fetch enwiki-latest-pagelinks.sql.gz
fetch enwiki-latest-categorylinks.sql.gz
fetch enwiki-latest-redirect.sql.gz
rm ./*.csv
