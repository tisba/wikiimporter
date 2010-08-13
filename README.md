# WikiImporter
First of all WikiImporter is a lame name! It is a set of tools for importing Wikipedia dumps to CouchDB. The parser currently only extracts the page ID, title, text, version ID and the timestamp of the latest change. For CouchDB document IDs currently the page title is used.

## Requirements

    gem install nokogiri trollop yajl-ruby

## Getting started
Try `./bin/wiki2couch.sh enwiki http://localhost:5984/enwiki` and have a look at what your Couch is doing :)

## What's in the box?
WikiImporter consists of 4 tools:

* `./bin/getlatestdumpurl.rb`, a helper to get the URL to the latest Wikipedia dump
* `./bin/wikixml2json.rb`, a parser for processing the XML dump and spitting out JSON objects (separated by newlines)
* `./bin/couch_upload.rb`, a tool for reading JSON objects from STDIN, batching them and upload them to CouchDB
* The fourth tool is `./bin/wiki2couch.sh`, which just invokes the other three tools and chaining them together. It requires two parameters: 1) the wiki language you want to import, 2) the full target CouchDB URL.

Try `--help` on `./bin/wikixml2json.rb` and `./bin/couch_upload.rb` to get more information.

`./bin/getlatestdumpurl.rb` takes one optional parameter which determines the language of the dump you want to download. Examples: `dewiki`, `enwiki`.


## Separated steps, more control
This is how you import the first 10000 articles from the German Wikipedia to your CouchDB running at `http://localhost:5984/`:

    curl -X DELETE http://localhost:5984/dewiki
    curl -X PUT http://localhost:5984/dewiki
    
    curl `./bin/getlatestdumpurl.rb dewiki` -o data/dewiki.xml.bz2
    
    bzcat data/dewiki.xml.bz2 | ./bin/wikixml2json.rb --max-pages 10000 > data_processed/articles.json
    
    cat data_processed/articles.json | ./bin/couch_upload.rb --couch-url "http://localhost:5984/wiki" --max-chunk-size 1500000

# Anything else?
WikiImporter also comes with a fulltext view (for couchdb-lucene), a show function and a view to play around with. Install them by: `cd wiki && couchapp push http://localhost:5984/wiki`.
