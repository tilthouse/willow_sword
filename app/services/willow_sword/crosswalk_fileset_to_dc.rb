module WillowSword
  class CrosswalkFilesetToDc < CrosswalkToXml
    attr_reader :file_set, :doc

    def initialize(file_set)
      @file_set = file_set
      @doc = nil
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
      <id>#{@file_set.id}</id>
      <title>#{@file_set.title.first}</title>
      <updated>#{@file_set.date_modified}</updated>"
      @doc = LibXML::XML::Document.string(atom)
    end

    def add_links
      # content url
      content_url = collection_work_file_set_url(params[:collection_id], params[:work_id], @file_set)
      @doc.root << content_node(content_url)
      # edit url
      edit_url = collection_work_file_set_url(params[:collection_id], params[:work_id], @file_set)
      @doc.root << link_node(edit_url)
    end

    def add_dc
      xw = WillowSword::CrosswalkFromDc.new(nil, nil)
      @file_set.attributes.each do |attr, values|
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
