#!/bin/sh

mkdir -p data/
cd data
curl -O http://download.wikimedia.org/dewiki/latest/dewiki-latest-pages-articles.xml.bz2
bzip2 --keep --decompress dewiki-latest-pages-articles.xml.bz2
cd ..