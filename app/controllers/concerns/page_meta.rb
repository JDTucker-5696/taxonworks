# TODO: Revist where this is used 
module PageMeta
  extend ActiveSupport::Concern

  included do

    # Potentially used
    attr_writer :meta_title, :meta_data, :site_name
    attr_accessor :meta_description, :meta_keywords, :page_title

    def meta_title
      @meta_title ||= [@meta_title.presence || @page_title.presence, site_name].compact.join(' | ')
    end

    def meta_data
      @meta_data ||= {
        description: @meta_description,
        keywords: @meta_keywords
      }.delete_if { |_k, v| v.nil? }
    end

    def site_name
      @site_name ||= 'TaxonWorks'
    end

    helper_method :meta_title, :meta_data, :site_name, :page_title

  end

end
