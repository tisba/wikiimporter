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

class MediaWikiToJSONParser < Nokogiri::XML::SAX::Document
    def initialize(logger, max_chunk_size, max_pages = -1, bundle_output = nil)
      @page_count = 0

      @text = ""
      @chunk_page_count = 0
      
      @output = (bundle_output == "--") ? $stdout : nil
      
      @bundle_output = bundle_output || "data_bundles/%07i.json"

      @max_chunk_size = max_chunk_size
      @max_pages = max_pages
      
      @logger = logger   
      
      @element_path = []
    end


    def start_element(name, attributes)
      @element_path << name
      
      if @element_path.last == "page"
        abort_check if @max_pages > 0
        start_article
        @article_id = nil
      end
      
      @char_buffer = ""
    end

    def end_element(name)
      case @element_path
      when ["mediawiki", "page"]
        end_article
        
      when ["mediawiki", "page", "id"]
        @article_id = @char_buffer
        @output << '"page_id": "' << @char_buffer << '",'
        # @output << '"_id": "' << @char_buffer << '",'

      when ["mediawiki", "page", "title"]
        @output << '"title": ' << Yajl::Encoder.encode(@char_buffer) << ','

      when ["mediawiki", "page", "revision", "timestamp"]
        @output << '"timestamp": ' << Yajl::Encoder.encode(@char_buffer) << ','

      when ["mediawiki", "page", "revision", "id"]
        @output << '"_id": "' << @article_id << "-" << @char_buffer << '",'
        # @output << '"revision_id": "' << @char_buffer << '",'

      when ["mediawiki", "page", "revision", "text"]
        @output << '"text": ' << Yajl::Encoder.encode(@char_buffer)

      end

      @char_buffer = ""
      @element_path.pop
    end

    def characters(data)
      @char_buffer << data if [ ["mediawiki", "page", "id"],
                                ["mediawiki", "page", "title"],
                                ["mediawiki", "page", "revision", "timestamp"],
                                ["mediawiki", "page", "revision", "id"],
                                ["mediawiki", "page", "revision", "text"]].include? @element_path
    end
 
    def start_article
      @page_count = @page_count + 1

      start_bundle if @output.nil?
      @output << "," if @chunk_page_count > 0 && @bundle_output != "--"
      @output << "{"
    end
    def end_article
      @output << "}"
      @chunk_page_count = @chunk_page_count + 1
      
      if @bundle_output == "--"
        @output << "\n"
      else
        end_bundle if @output.pos >= @max_chunk_size
      end
      
    end

    def start_bundle
      if @bundle_output == "--"
        # @output << "\nXXXXXXXXXXXXX\n" #if @page_count > 0
      else
        filename = @bundle_output % @page_count
        log "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] Starting new bundle: #{filename}"
        @output = File.new(filename, "w")
      end
      @output << '{"docs": ['
      @chunk_page_count = 0
    end
    def end_bundle
      return if @output.nil? || @output.closed? #|| @state == :closed_bundle
      @output << ']}'
      @chunk_page_count = 0

      if @bundle_output == "--"
        @output << "\n"
        # @state = :closed_bundle
      else
        @output.close
        @output = nil
      end
    end

    def log(message)
      @logger.puts message
    end


    def abort_check
      if @page_count >= @max_pages
        end_bundle unless @bundle_output == "--"
        exit
      end
    end
end