#!/usr/bin/env ruby

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

require "rubygems"

require "nokogiri"
require "yajl"
require "trollop"

require "lib/mediawiki_to_json_parser"

require "logger"

# gather command line options
opts = Trollop.options do
  opt :input_file, "Wikipedia XML dump file (- for STDIN)", :type => String, :default => "-" 
  opt :max_pages, "Number of articles to be imported (-1 for all)", :type => :int, :default => -1
  opt :skip_pages, "Number of articles to be skipped (NOT YET IMPLEMENTED)", :type => :int, :default => 0
  opt :logfile, "Logfile", :type => String, :default => "log/wikixml2json.log"
end

# setting up the parser
mediawikiparser = MediaWikiToJSONParser.new(Logger.new(opts[:logfile]), opts)
parser = Nokogiri::XML::SAX::Parser.new(mediawikiparser)

# Send some XML to the parser :)
if opts[:input_file] == "-"
  parser.parse_io(STDIN, "UTF-8")
else
  parser.parse_file(opts[:input_file])
end