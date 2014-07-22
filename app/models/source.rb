# A Source is the metadata that identifies the origin of some information.

# The primary purpose of Source metadata is to allow the user to find the source, that's all. 
# 
class Source < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::Identifiable
  include Shared::HasRoles
  include Shared::Notable
  include Shared::AlternateValues
  include Shared::DataAttributes
  include Shared::Taggable

  has_many :citations, inverse_of: :source, dependent: :destroy
  has_many :cited_objects, through: :citations, source: :citation_object, dependent: :destroy # not ordered

  #validate :not_empty

  protected
  
  # def not_empty
  #   # a source must have content in some field
  # end

end
