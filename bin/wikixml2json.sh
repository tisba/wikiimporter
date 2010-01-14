#!/bin/sh

rm -rf data_bundles/
mkdir -p data_bundles/
time ruby parser2.rb
du -h data_bundles/