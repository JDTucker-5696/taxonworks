module ConfidencesHelper

  def confidence_tag(confidence)
    return nil if confidence.nil?
    content_tag(:span, confidence.confidence_level.name, style: "background-color: #{confidence.confidence_level.css_color};")
  end

  def confidence_link(confidence)
    return nil if confidence.nil?
    link_to(confidence_tag(confidence), confidence.confidence_object.metamorphosize)
  end

  # @return [String (html), nil]
  #    a ul/li of tags for the object
  def confidence_list_tag(object)
    return nil unless object.has_confidences? && object.confidences.any?
    content_tag(:h3, 'Confidences') +
      content_tag(:ul, class: 'annotations__confidences_list') do
      object.confidences.collect { |a| content_tag(:li, confidence_tag(a)) }.join.html_safe
    end
  end

  def confidence_annotation_confidence(confidence)
    return nil if confidence.nil?
    content_tag(:span, controlled_vocabulary_term_tag(confidence.confidence_level), class: [:annotation__confidence])
  end

  def confidences_search_form
    render('/confidences/quick_search_form')
  end

  def add_confidence_link(object: nil)
    link_to('Add confidence', new_confidence_path( 
                                                  confidence_object_type: object.class.base_class.name,
                                                  confidence_object_id: object.id
                                                 )) if object.has_confidences?
  end

end
