module ImagesHelper

  # !! Rails already provides image_tag, i.e. it is not required here.

  def image_link(image)
    return nil if image.nil?
    link_to(image_tag(image.image_file.url(:thumb)), image)
  end

  def images_search_form
    render('/images/quick_search_form')
  end

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def images_recent_objects_partial
    true 
  end

  def image_autocomplete_tag(image)
    content_tag(:figure) do
      (
        image_tag(image.image_file.url(:thumb)) +
        content_tag(:caption, "id:#{image.id}", class: ['feedback', 'feedback-primary', 'feedback-thin']) 
      ).html_safe
    end
  end

  # <div class="easyzoom easyzoom--overlay">
  #   <a href="<%= @image.image_file.url(:medium) %>">
  #     <%= image_tag(@image.image_file.url(:medium), 'class' => 'imageZoom') %>
  #   </a>
  # </div>

  def thumb_list_tag(object)
    if object.depictions.any?
      object.depictions.collect{|a|
        content_tag(:div, class: [:easyzoom, 'easyzoom--overlay'])  do
          link_to( depiction_tag(a, size: :medium), a.image.image_file.url())
        end
      }.join.html_safe
    end
  end

end
