# Wikipedia on CouchDB
Type...

    ./mediawiki2couch.sh

...wait... and have fun!

    curl --silent `ruby bin/getlatestdumpurl.rb` | bzcat | ruby bin/wikixml2json.rb -- 5000000 -1

    bzcat data/dewiki-latest-pages-articles.xml.bz2 | ruby bin/wikixml2json.rb -- 1_000_000 100_000 -- | ./bin/couch_upload.rb

get the latest dump

    curl `ruby bin/getlatestdumpurl.rb` -O


    time find data_bundles -name \*json -exec curl -\# -w "%{time_total} sec\n" -T {} -X POST http://localhost:5984/wikicouch/_bulk_docs > couch_upload.log \;

# TODOs
- Add options to Scripts :)
  - Couch-URL

# komplett transformation und import


    couchdb='http://localhost:5984/wikicouch'
    
    rm -rf data_bundles
    mkdir data_bundles
    
    curl -X DELETE ${couchdb}
    curl -X PUT ${couchdb}

    time bzcat data/dewiki-20100206-pages-articles.xml.bz2 | ruby bin/wikixml2json.rb

    # clear the upload log, do the upload and fetch processing times for each chunk
    rm couch_upload.log
    time find data_bundles -name \*json -exec curl -\# -w "%{time_total} sec\n" -T {} -X POST http://localhost:5984/wikicouch/_bulk_docs > couch_upload.log \;
    grep -E '^[0-9]+\.[0-9]+ sec$' couch_upload.log 


# Test



    maxpages=1000
    couchdb='http://localhost:5984/wikicouch'
    rm -rf data_budles/
    mkdir -p data_bundles/alt
    mkdir -p data_bundles/neu
    bzcat data/dewiki-20091223-pages-articles.xml.bz2 | ./bin/wikixml2json.rb -- 5_000_000 $maxpages "data_bundles/alt/%07i.json"
    bzcat data/dewiki-20100206-pages-articles.xml.bz2 | ./bin/wikixml2json.rb -- 5_000_000 $maxpages "data_bundles/neu/%07i.json"

    curl -X DELETE ${couchdb}
    curl -X PUT ${couchdb}

    time find data_bundles/alt/ -name \*json -exec curl -\# -w "%{time_total} sec" -T {} -X POST ${couchdb}/_bulk_docs > couch_upload.log \;
    time find data_bundles/neu/ -name \*json -exec curl -\# -w "%{time_total} sec" -T {} -X POST ${couchdb}/_bulk_docs > couch_upload.log \;

    curl -X GET ${couchdb}/_design/wiki/_view/by_timestamp
    
    
    curl -X GET 'http://localhost:5984/wikicouch/_design/wiki/_view/by_title?endkey=\[%22Zusammenhang%20von%20Graphen%22\]&startkey=\[%22Zusammenhang%20von%20Graphen%22,{}\]&descending=true&limit=1'