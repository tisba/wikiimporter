#!/bin/sh

echo "Trying to delete and create target DB"
curl -X DELETE http://localhost:5984/wikicouch/
curl -X PUT http://localhost:5984/wikicouch/

echo "Uploading document chunks"
time find data_bundles -name '*.json' -exec curl -# -X POST -d @{} http://localhost:5984/wikicouch/_bulk_docs >> couch_upload.log \;