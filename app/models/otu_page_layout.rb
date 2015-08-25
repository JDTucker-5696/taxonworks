class OtuPageLayout < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 


  has_many :otu_page_layout_sections, inverse_of: :otu_page_layout, dependent: :destroy
  has_many :topics, through: :otu_page_layout_sections
  accepts_nested_attributes_for :topics

  validates_presence_of :name
end
