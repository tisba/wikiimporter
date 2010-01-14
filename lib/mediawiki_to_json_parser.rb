class MediaWikiToJSONParser < Nokogiri::XML::SAX::Document
    def initialize(max_chunk_size, max_pages = -1)
      @page_count = 0

      @state = :page

      @text = ""
      @chunk_size = 0
      @bundle_fd = nil

      @max_chunk_size = max_chunk_size
      @max_pages = max_pages
    end

    def start_element(name, attributes)
      if name == "page"
        abort_check if @max_pages > 0
        start_article
      end

      if name == "title"
        @state = :title
      end
      if name == "id" && @state == :after_title
        @state = :page_id
      end
      if name == "text"
        @state = :text
      end
      if name == "timestamp"
        @state = :timestamp
      end
    end

    def end_element(name)
      end_article if name == "page"

      if name == "text"
        @bundle_fd << '"text": '
        # @bundle_fd << '"foo"'
        @bundle_fd << Yajl::Encoder.encode(@text)

        @text = ""
        @state = :page
      end
    end

    def characters(data)
      case @state
      when :timestamp
        @bundle_fd << '"timestamp": "' << data << '",'
        @state = :page
      when :page_id
        # @article[:_id] = data.to_s
        @bundle_fd << '"_id": "' << data << '",'
        @state = :page
      when :title
        @bundle_fd << '"title": ' << Yajl::Encoder.encode(data) << ','
        @state = :after_title
        # puts data
        # @state = :page
      when :text
        @text << data
      end
    end

    def start_article
      @page_count = @page_count + 1

      start_bundle if @bundle_fd.nil?
      @bundle_fd << "," if @chunk_size > 0
      @bundle_fd << "{"
    end
    def end_article
      @bundle_fd << "}"
      @chunk_size = @chunk_size + 1
      end_bundle if @chunk_size >= @max_chunk_size
    end

    def start_bundle
      filename = "data_bundles/%07i.json" % @page_count
      puts "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] Starting new bundle: #{filename}"
      @bundle_fd = File.new(filename, "w")
      @bundle_fd << '{"docs": ['
      @chunk_size = 0
    end
    def end_bundle
      return if @bundle_fd.nil? || @bundle_fd.closed?
      @bundle_fd << ']}'
      @bundle_fd.close
      @bundle_fd = nil
      @chunk_size = 0
    end

    def abort_check
      return if @state == :skipping
      if @page_count >= @max_pages
        end_bundle
        exit
      end
    end
end