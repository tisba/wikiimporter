#!/usr/bin/env ruby

# Copyright (c) 2010-2012 Sebastian Cohnen
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

require File.expand_path('../../lib/boot', __FILE__)

require "open-uri"

wiki_lang = ARGV[0] || "dewiki"
feed_url = "http://download.wikimedia.org/#{wiki_lang}/latest/#{wiki_lang}-latest-pages-articles.xml.bz2-rss.xml"

latest_dump_date = Nokogiri::XML(open(feed_url)).xpath('//item/link').children.first.text.match(/\d+/)[0]

puts "http://dumps.wikimedia.org/#{wiki_lang}/#{latest_dump_date}/#{wiki_lang}-#{latest_dump_date}-pages-articles.xml.bz2"