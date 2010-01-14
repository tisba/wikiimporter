#!/bin/sh

cd bin
./fetchdump.sh && ./wikixml2json.sh && ./upload.sh
cd ..
echo "Done"
