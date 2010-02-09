require "rubygems"
require "nokogiri"
require "open-uri"

feed_url = 'http://download.wikimedia.org/dewiki/latest/dewiki-latest-pages-articles.xml.bz2-rss.xml'

date = Nokogiri::XML(open(feed_url)).xpath('//item/link').children.first.text.match(/\d+/)[0]
# url = "http://download.wikimedia.org/dewiki/#{date}/dewiki-#{date}-pages-articles.xml.bz2"

puts date