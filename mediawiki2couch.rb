#!/usr/bin/ruby -w

require "rubygems"

require "nokogiri"
require "open-uri"
require "yajl"

require "lib/mediawiki_to_json_parser"

start_time = Time.now

current_working_dir = FileUtils.pwd



def latest_dump_date(feed_url)
  Nokogiri::XML(open(feed_url)).xpath('//item/link').children.first.text.match(/\d+/)[0]
end


# get latest wiki-dump date
feed_url = 'http://download.wikimedia.org/dewiki/latest/dewiki-latest-pages-articles.xml.bz2-rss.xml'


latest_dump_date = "20091223"

wiki_lang = "dewiki"
data_dir = "data/"
data_bundles_dir = "data_bundles/"


# construct dump-filename, url, ...
dump_filename="#{wiki_lang}-#{latest_dump_date}-pages-articles.xml.bz2"
dump_xml_filename="#{wiki_lang}-#{latest_dump_date}-pages-articles.xml"
dump_url="http://download.wikimedia.org/#{wiki_lang}/#{latest_dump_date}/#{dump_filename}"
md5sum_url="http://download.wikimedia.org/#{wiki_lang}/#{latest_dump_date}/#{wiki_lang}-#{latest_dump_date}-md5sums.txt"

def download_dump
  # create download dir (if not already present) and change dir
  FileUtils.mkpath data_dir
  FileUtils.cd data_dir

  system "curl -O \"#{dump_url}\""
end

def verify_download
  system "curl --silent #{md5sum_url} | grep #{dump_filename} | md5sum --status -c -"
  if $? == 0
    puts "download verified!"
  else
    puts "download validation failed!"
    exit 1
  end
end


# download_dump
# verify_download
# decompress_dump



# Prepare wikixml2json
puts "Purging data_bundles/*"
FileUtils.rmtree data_bundles_dir
FileUtils.mkpath data_bundles_dir

# Start the parser
puts "Starting parser..."
system "bzcat data/#{dump_filename} | ruby bin/wikixml2json.rb -- 1000 10000"

end_time = Time.now

puts "Elapsed time: #{end_time - start_time}"
