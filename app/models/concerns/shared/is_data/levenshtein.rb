# Shared code for...
#
module Shared::IsData::Levenshtein
  extend ActiveSupport::Concern

  included do
    # include Users
    has_many :pinboard_items, as: :pinned_object, dependent: :destroy
  end

  # @param [String, String, Integer]
  # @return [Scope]
  def nearest_by_levenshtein(compared_string = nil, column = nil, limit = 10)
    return self.class.none if compared_string.nil? || column.nil?
    order_str = self.class.send(:sanitize_sql_for_conditions, ["levenshtein(left(#{self.class.table_name}.#{column}, 255), ?)", compared_string[0.254] ])
    self.class.where('id <> ?', self.to_param).
      order(order_str).
      limit(limit)
  end

end
