#!/usr/bin/ruby -w

# Copyright (c) 2010 Sebastian Cohnen
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# TODO
# - better command line option parsing
# - zero-padded IDs?
# - auslagern des "bundling-codes" in eine eigene anwendung?

require "rubygems"

require "nokogiri"
require "yajl"

require "lib/mediawiki_to_json_parser"

# reading ARGVs and/or setting defaults
input_file = ARGV[0] || "--" # use stdin for default
max_chunk_size = (ARGV[1] || 5_000_000).to_i  # try to limit document bundles to X bytes
max_pages = (ARGV[2] || -1).to_i  # -1 means all pages
bundle_output = ARGV[3] || "data_bundles/%07i.json" # give printf-style pattern for output

$log_fd = $stdout

def log(message)
  $log_fd.puts message
end

if bundle_output == "--"
  $log_fd = File.open("wikixml2json.log", "a")
end

# be a little bit chatty :)
if input_file == "--"
  log "Using $stdin for input"
else
  log "Input #{input_file}"
end


log "Trying to limit size of chunks to #{max_chunk_size} bytes"
log "Using output schema #{bundle_output}"
log max_pages > 0 ? "Parsing up to #{max_pages} pages" : "Parsing all pages"

# setting up the parser
mediawikiparser = MediaWikiToJSONParser.new($log_fd, max_chunk_size, max_pages, bundle_output)
parser = Nokogiri::XML::SAX::Parser.new(mediawikiparser)

# Send some XML to the parser :)
if input_file == "--"
  parser.parse_io($stdin, "UTF-8")
else
  parser.parse_file(input_file)
end

# Ensure, that the last bundle is properly written (this is ugly I know)
mediawikiparser.end_bundle
