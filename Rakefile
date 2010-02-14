require 'rubygems'
require 'rake'

desc "Remove generated data"
task :cleanup do
  puts "Cleaning up..."
  system "rm -rf data_budles/"
end

desc "Reset the couch"
task :reset_database, [:couch_url] do |t, args|
  puts "couch_url: #{args.couch_url}"
  exit
  system "curl -X DELETE #{args.couch_url}"
  # system "curl -X PUT #{couch_url}"
end

desc "Initialize "
task :bootstrap do
  puts "Bootstrapping..."
  system "mkdir -p data/"
  system "mkdir -p data_bundles/alt"
  system "mkdir -p data_bundles/neu"
end

desc "Parse the wiki dump to JSON"
task :parse_xml  => [:cleanup, :bootstrap] do
  maxpages = 1_000

  data_bundle_new = "data_bundles/neu/%07i.json"
  data_bundle_old = "data_bundles/alt/%07i.json"
  
  system "bzcat data/dewiki-20091223-pages-articles.xml.bz2 | ./bin/wikixml2json.rb -- 5_000_000 #{maxpages} #{data_bundle_old}"
  system "bzcat data/dewiki-20100206-pages-articles.xml.bz2 | ./bin/wikixml2json.rb -- 5_000_000 #{maxpages} #{data_bundle_new}"
end

desc "Import the JSON to couch"
task :import_json do
  `time find data_bundles/alt/ -name *json -exec curl -# -w "%{time_total} sec" -T {} -X POST #{couch_url}/_bulk_docs > couch_upload.log \;`
  `time find data_bundles/neu/ -name *json -exec curl -# -w "%{time_total} sec" -T {} -X POST #{couch_url}/_bulk_docs > couch_upload.log \;`
end  


