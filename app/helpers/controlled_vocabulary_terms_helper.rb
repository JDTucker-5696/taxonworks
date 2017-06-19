module ControlledVocabularyTermsHelper

  def controlled_vocabulary_term_tag(controlled_vocabulary_term)
    return nil if controlled_vocabulary_term.nil?
    content_tag(:span, color_tag(controlled_vocabulary_term.css_color, controlled_vocabulary_term.name), title: controlled_vocabulary_term.definition)
  end

  def controlled_vocabulary_term_link(controlled_vocabulary_term)
    return nil if controlled_vocabulary_term.nil?
    link_to(controlled_vocabulary_term_tag(controlled_vocabulary_term.metamorphosize).html_safe, controlled_vocabulary_term.metamorphosize)
  end

  def controlled_vocabulary_term_type_select_options
    %w[Keyword Topic Predicate BiologicalProperty BiocurationGroup BiocurationClass ConfidenceLevel]
  end

  def term_and_definition_tag(controlled_vocabulary_term)
    content_tag(:span, controlled_vocabulary_term) + ': ' + content_tag(:span, controlled_vocabulary_term.definition)
  end

  def controlled_vocabulary_terms_search_form
    render('/controlled_vocabulary_terms/quick_search_form')
  end

  # TODO: make the color an attribute and apply it after, give a border
  def color_tag(css_color = nil, value)
    return value if css_color.nil?
    content_tag(:span, value, style: "background-color: #{css_color};")
  end

end
