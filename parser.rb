#!/usr/bin/ruby -w

# TODO
# - zero-padded IDs?
# - import more data (which one?)

require "rubygems"
require "nokogiri"
require "yajl"

require "lib/mediawiki_to_json_parser"

input_file = "data/dewiki-20091223-pages-articles.xml"
max_chunk_size = 1_000
max_pages = 1_000_000

mediawikiparser = MediaWikiToJSONParser.new(max_chunk_size, max_pages)
parser = Nokogiri::XML::SAX::Parser.new(mediawikiparser)

puts "Input #{input_file}"
puts "Size of chunks: #{max_chunk_size} pages per chunk"
puts max_pages > 0 ? "Parsing up to #{max_pages} pages" : "Parsing all pages"
puts "starting..."

# Send some XML to the parser
parser.parse_file(input_file)

# Ensure, that the last bundle is properly written
mediawikiparser.end_bundle
