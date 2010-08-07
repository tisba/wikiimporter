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

require "rubygems"
require "trollop"
require "pp"
require "stringio"
require "logger"

STDOUT.sync = true

class CouchUpload
  attr_reader :opts
  attr_reader :log

  def initialize(opts)
    @opts = opts
    create_target_db if opts[:create_db]

    @log = if opts[:logfile] == "-"
      Logger.new(STDOUT)
    else
      Logger.new(opts[:logfile])
    end
  end

  def bulk_upload(payload)
    cmd = "curl -# -H \"Content-Type: application/json\" --upload-file - -X POST #{opts[:couch_url]}/_bulk_docs -w\"%{http_code}\ %{time_total}\" >> #{opts[:curl_log]}"
    @log.debug "cmd: #{cmd}"
    @log.info "flushing #{payload.length} bytes"

    if opts[:debug]
      puts '{"docs":[' << payload << ']}'
      return if true
    else
      IO.popen(cmd, "w+") do |curl|
        curl.sync = true
        curl.puts '{"docs":[' << payload << ']}'
        curl.close_write
      end
    end
  end

  def fetch_input_and_process
    buffer = StringIO.new
    while (payload = STDIN.gets)
      buffer << "," if buffer.length > 0
      buffer << payload.strip!

      if buffer.length > opts[:max_chunk_size]
        bulk_upload buffer.string
        buffer = StringIO.new
      end
    end

    bulk_upload buffer.string if buffer.length > 0
  end

  def create_target_db
    `curl -X DELETE #{opts[:couch_url]} --silent`
    `curl -X PUT #{opts[:couch_url]} --silent`
  end
end


# gather command line options
opts = Trollop.options do
  opt :max_chunk_size, "Target size of output bundles", :type => :int, :default => 5_000_000
  opt :debug, "Don't upload bundles", :default => false
  opt :couch_url, "CouchDB to push to", :type => :string
  opt :create_db, "Create target database, if needed", :default => true
  opt :logfile, "Logfile, - for STDOUT", :default => "log/couch_upload.log"
  opt :curl_log, "Logfile for curl", :default => "log/curl_out.log"

  educate and exit if STDIN.tty?
end

cp = CouchUpload.new(opts)
cp.fetch_input_and_process
