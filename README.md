# Wikipedia on CouchDB
Type...

    ./mediawiki2couch.sh

...wait... and have fun!

    curl --silent `ruby bin/getlatestdumpurl.rb` | bzcat | ruby bin/wikixml2json.rb -- 5000000 -1

    bzcat data/dewiki-latest-pages-articles.xml.bz2 | ruby bin/wikixml2json.rb -- 1_000_000 100_000 -- | ./bin/couch_upload.rb

# TODOs
- Add options to Scripts :)
  - Couch-URL
  - Make bulk_doc-bundle size configureable
  - Skip-DL, give direct input XML