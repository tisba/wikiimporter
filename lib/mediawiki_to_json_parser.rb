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

    @output = STDOUT

    @max_pages = opts[:max_pages]
    
    @logger = logger
    
    @element_path = []
    @element_path_sym = nil

    # be a little bit chatty :)
    if opts[:input_file] == "-"
      log "Using STDIN for input"
    else
      log "Input #{opts[:input_file]}"
    end

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
      # @article_id = @char_buffer.string.strip
      # @output << '"page_id": "' << @article_id << '",'
      @output << '"page_id": "' << @char_buffer.string.strip << '",'

    when :"mediawiki,page,title"
      @article_id = Yajl::Encoder.encode(@char_buffer.string)
      @output << '"title": ' << @article_id << ','
      @output << '"_id": ' << @article_id << ','
      # @output << '"title": ' << Yajl::Encoder.encode(@char_buffer.string) << ','

    when :"mediawiki,page,revision,timestamp"
      @output << '"timestamp": ' << Yajl::Encoder.encode(@char_buffer.string) << ','

    when :"mediawiki,page,revision,id"
      # @output << '"_id": "' << @article_id << "-" << @char_buffer.string << '",'
      @output << '"revision_id": "' << @char_buffer.string << '",'

    when :"mediawiki,page,revision,text"
      @output << '"text": ' << Yajl::Encoder.encode(@char_buffer.string)
      # @output << '"text": ' << '"........"'
    end

    @element_path.pop
    @element_path_sym = :"#{@element_path.join(",")}"
  end

  def characters(data)
    @char_buffer.write(data)
  end



  def start_article
    @page_count = @page_count + 1
    @output << "{"
  end
  def end_article
    @output << "}"
    @output << "\n"
  end

  def log(message)
    @logger.debug message
  end

  def abort_check
    exit if @page_count >= @max_pages
  end
end