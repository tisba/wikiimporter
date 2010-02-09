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

require "pp"

max_chunk_size = (ARGV[0] || 5_000_000).to_i  # try to limit document bundles to X bytes

puts "I'm couch_upload..."
buffer = ""

cmd = "curl --upload-file - -X POST http://localhost:5984/wikicouch/_bulk_docs -w\"%{http_code}\ %{time_total}\" -o out.file 2> /dev/null"


while (payload = $stdin.gets)
  
  buffer << payload.strip!
  
  if buffer.length > max_chunk_size
    puts "flushing #{buffer.length} bytes"

    curl_io = IO.popen(cmd, "w+")
    curl_io.puts '{"docs":[' << buffer << ']}'
    curl_io.close_write
    puts curl_io.gets

    buffer = ""
  else
    buffer << ","
  end
end


if buffer.length != 0
  puts "flushing #{buffer.length} bytes"

  curl_io = IO.popen(cmd, "w+")
  curl_io.puts '{"docs":[' << buffer << ']}'
  curl_io.close_write
  puts curl_io.gets
end
