#!/usr/bin/env bash

[ -z "$1" ] && echo "Language to import missing!" && exit 1
[ -z "$2" ] && echo "Target CouchDB missing!" && exit 1

curl `./bin/getlatestdumpurl.rb $1` --silent | \
bzcat | \
./bin/wikixml2json.rb | \
./bin/couch_upload.rb --couch-url $2 