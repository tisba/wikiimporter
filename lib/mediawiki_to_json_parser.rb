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

require "stringio"

class MediaWikiToJSONParser < Nokogiri::XML::SAX::Document
  def initialize(logger, opts)
    @page_count = 0

    @chunk_page_count = 0
    
    @do_bundle = !opts[:no_bundles]

    @output = (!@do_bundle || opts[:bundle_output] == "-") ? STDOUT : nil
    @bundle_output = opts[:bundle_output] || "data_bundles/%07i.json"
    
    @max_chunk_size = opts[:max_chunk_size]
    @max_pages = opts[:max_pages]
    
    @logger = logger   
    
    @element_path = []
    @element_path_sym = nil

    # be a little bit chatty :)
    if opts[:input_file] == "-"
      log "Using $stdin for input"
    else
      log "Input #{opts[:input_file]}"
    end

    log "Trying to limit size of chunks to #{opts[:max_chunk_size]} bytes"
    log "Using output schema #{opts[:bundle_output]}"
    log opts[:max_pages] > 0 ? "Parsing up to #{opts[:max_pages]} pages" : "Parsing all pages"
  end



  def start_element(name, attributes)
    @element_path << name
    @element_path_sym = :"#{@element_path.join(",")}"
    
    if @element_path_sym == :"mediawiki,page"
      abort_check if @max_pages > 0
      start_article
      @article_id = nil
    end
    
    @char_buffer = StringIO.new
  end

  def end_element(name)
    case @element_path_sym
    when :"mediawiki,page"
      end_article
    when :"mediawiki,page,id"
      @article_id = @char_buffer.string.strip
      @output << '"page_id": "' << @article_id << '",'

    when :"mediawiki,page,title"
      @output << '"title": ' << Yajl::Encoder.encode(@char_buffer.string) << ','

    when :"mediawiki,page,revision,timestamp"
      @output << '"timestamp": ' << Yajl::Encoder.encode(@char_buffer.string) << ','

    when :"mediawiki,page,revision,id"
      @output << '"_id": "' << @article_id << "-" << @char_buffer.string << '",'
      @output << '"revision_id": "' << @char_buffer.string << '",'

    when :"mediawiki,page,revision,text"
      # @output << '"text": ' << Yajl::Encoder.encode(@char_buffer.string)
      @output << '"text": ' << '"........"'
    end

    @element_path.pop
    @element_path_sym = :"#{@element_path.join(",")}"
  end

  def characters(data)
    @char_buffer.write(data)
  end



  def start_article
    @page_count = @page_count + 1

    if @do_bundle
      start_bundle if @chunk_page_count == 0
      @output << "," if @chunk_page_count > 0
    end
    @output << "{"
  end
  def end_article
    @output << "}"
    @chunk_page_count = @chunk_page_count + 1
    
    if @do_bundle && @output.pos >= @max_chunk_size
      end_bundle
    else
      @output << "\n"
    end
  end



  def start_bundle
    if @bundle_output != "-"
      filename = @bundle_output % @page_count
      log "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] Starting new bundle: #{filename}"
      @output = File.new(filename, "w")
    end
    @output << '{"docs": ['
    @chunk_page_count = 0
  end
  def end_bundle
    @output << ']}'
    @chunk_page_count = 0
    unless @bundle_output == "-" # only close and reset fd when using a file
      @output.close
      @output = nil
    end
  end




  def log(message)
    @logger.puts message
  end


  def abort_check
    if @page_count >= @max_pages
      end_bundle unless @bundle_output == "-"
      exit
    end
  end
end