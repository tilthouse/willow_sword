module WillowSword
  class CrosswalkWorkToDc < CrosswalkToXml
    attr_reader :work, :doc

    def initialize(work, params=nil)
      @work = work
      @doc = nil
      @params = params
    end

    def to_xml
      atom_root
      add_links
      add_dc
    end

    def atom_root
      atom = "<?xml version='1.0' encoding='utf-8'?>
      <feed
        xmlns='http://www.w3.org/2005/Atom'
        xmlns:dcterms='http://purl.org/dc/terms/'
        xmlns:dc='http://purl.org/dc/elements/1.1/'
      >
        <id>#{@work.id}</id>
        <title>#{@work.title.first}</title>
        <updated>#{@work.date_modified}</updated>
      </feed>"
      @doc = LibXML::XML::Document.string(atom)
    end

    def add_links
      # content url
      @doc.root << content_node(@params[@work.id][:content])
      # edit url
      @doc.root << link_node(@params[@work.id][:edit])
      @work.file_sets.each do |file_set|
        entry = create_node('entry')
        @doc.root << entry
        id_node = create_node('id', file_set.id)
        entry << id_node
        title_node = create_node('title', file_set.title.first)
        entry << title_node
        udate_node = create_node('updated', file_set.date_modified)
        entry << udate_node
        entry << content_node(@params[file_set.id][:content])
        entry << link_node(@params[file_set.id][:edit])
      end
    end

    def add_dc
      xw = WillowSword::CrosswalkFromDc.new(nil, nil)
      @work.attributes.each do |attr, values|
        if xw.terms.include?(attr.to_s)
          term = xw.translated_terms.key(attr.to_s).present? ? xw.translated_terms.key(attr.to_s) : attr.to_s
          Array(values).each do |val|
            dc_node = create_node("dc:#{term}", val)
            @doc.root << dc_node
          end
        end
      end
    end


    private

    def content_node(content_url)
      create_node('content', nil, {
        'rel' => 'src',
        'href' => content_url
      })
    end

    def link_node(edit_url)
      create_node('link', nil, {
        'rel' => 'edit',
        'href' => edit_url
      })
    end

  end
end
