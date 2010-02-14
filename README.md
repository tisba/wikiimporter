# Wikipedia on CouchDB
Type...

    ./mediawiki2couch.sh

...wait... and have fun!

    curl --silent `ruby bin/getlatestdumpurl.rb` | bzcat | ruby bin/wikixml2json.rb -- 5000000 -1

    bzcat data/dewiki-latest-pages-articles.xml.bz2 | ruby bin/wikixml2json.rb -- 1_000_000 100_000 -- | ./bin/couch_upload.rb

get the latest dump

    curl `ruby bin/getlatestdumpurl.rb` -O


    time find data_bundles -name \*json -exec curl -\# -w "%{time_total} sec" -T {} -X POST http://localhost:5984/wikicouch/_bulk_docs > couch_upload.log \;

# TODOs
- Add options to Scripts :)
  - Couch-URL

