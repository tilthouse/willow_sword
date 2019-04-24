module WillowSword
  class CrosswalkWorkToDc < CrosswalkToXml
    attr_reader :work, :doc

    def initialize(work)
      @work = work
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
      <id>#{@work.id}</id>
      <title>#{@work.title.first}</title>
      <updated>#{@work.date_modified}</updated>"
      @doc = LibXML::XML::Document.string(atom)
    end

    def add_links
      # content url
      content_url = collection_work_url(params[:collection_id], @work)
      @doc.root << content_node(content_url)
      # edit url
      edit_url = collection_work_file_sets_url(params[:collection_id], @work)
      @doc.root << link_node(edit_url)
      @work.file_set_ids.each do |file_set_id|
        entry = create_node('entry')
        @doc.root << entry
        id_node = create_node('id', file_set_id.id)
        entry << id_node
        title_node = create_node('title', file_set_id.title.first)
        entry << title_node
        udate_node = create_node('updated', file_set_id.date_modified)
        entry << udate_node
        content_url = collection_work_file_set_url(params[:collection_id], @work, file_set_id)
        entry << content_node(content_url)
        edit_url = collection_work_file_set_url(params[:collection_id], @work, file_set_id)
        entry << link_node(edit_url)
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
