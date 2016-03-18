module SourcesHelper

  def source_tag(source)
    return nil if source.nil?
    source.cached ? source.cached : "WARNING CACHE NOT BUILT ADMIN TEST"
  end

  def sources_search_form
    render('/sources/quick_search_form')
  end

  def source_link(source)
    return nil if source.nil?
    link_to(source_tag(source).html_safe, source.metamorphosize )
  end

  def source_attributes_for(source)
    w = content_tag(:em, 'ERROR - contact admin.', class: :warning)  
    content_for :attributes do
      case source.class.name 
      when 'Source::Bibtex' 
        render partial: '/sources/bibtex/attributes'
      when 'Source::Verbatim'
        render partial: '/sources/verbatim/attributes'
      when 'Source::Source'
        w 
      else
        w
      end
    end
  end

  def source_related_attributes(source)
    content_for :related_attributes do
       if source.class.name == 'Source::Bibtex'
          content_tag(:h3, 'Authors') do
            content_tag(:ul) do
              source.authors.collect{|a| content_tag(:li, a.last_name)} 
            end
          end
       else

       end
    end
  end




  # TODO: write helper methods
  # context 'source format variations' do
  #   # a valid source ibtex should support the following output formats
  #   skip 'authority string - <author family name> year'
  #   skip 'short string - <author short name (as little of the author names needed to differentiate from other authors within current project)> <editor indicator> <year> <any containing reference - e.g. In Book> <Short publication name> <Series> <Volume> <Issue> <Pages>'
  #   skip 'long string - <full author names> <editor indicator> <year> <title> <containing reference> <Full publication name> <Series> <Volume> <Issue> <Pages>'
  #   skip 'no publication long string -<full author names> <editor indicator> <year> <title> <containing reference> <Series> <Volume> <Issue> <Pages>'
  # end

end
