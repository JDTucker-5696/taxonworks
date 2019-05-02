class ObservationMatrixRow < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Identifiers
  include Shared::IsData
  include Shared::Tags
  include Shared::Notes

  acts_as_list

  belongs_to :observation_matrix, inverse_of: :observation_matrix_rows
  belongs_to :otu, inverse_of: :observation_matrix_rows
  belongs_to :collection_object, inverse_of: :observation_matrix_rows

  def observation_matrix_columns
    ObservationMatrixColumn.where(observation_matrix_id: observation_matrix_id)
  end

  after_initialize :set_reference_count

  validates_presence_of :observation_matrix
  validate :otu_and_collection_object_blank
  validate :otu_and_collection_object_given
  
  validates_uniqueness_of :otu_id, scope: [:observation_matrix_id], if: -> {!otu_id.nil?}
  validates_uniqueness_of :collection_object_id, scope: [:observation_matrix_id], if: -> {!collection_object_id.nil?}

  # @param array [Array]
  # @return true
  #   incrementally sort the supplied ids
  def self.sort(array)
    array.each_with_index do |id, index|
      ObservationMatrixRow.where(id: id).update_all(position: index + 1) 
    end
    true
  end

  def set_reference_count
    self.reference_count ||= 0
  end

  def row_object
    # exit as quickly as possible
    if o = otu
      return o
    end
    if c = collection_object
      return c
    end
    nil
  end

  def row_object_class_name
    return 'Otu' if otu_id
    return 'CollectionObject' if collection_object_id
    raise
  end

  # TODO: belong in helpers
  def next_row
    observation_matrix.observation_matrix_rows.where("position > ?", position).order(:position).first 
  end

  def previous_row
    observation_matrix.observation_matrix_rows.where("position < ?", position).order('position DESC').first 
  end

  # @return [Scope]
  #  all the observations in this row, ordered (but not gathered)
  def observations
    t = Observation.arel_table

    a = t.alias
    b = t.project(a[Arel.star]).from(a)

    c = ObservationMatrixColumn.arel_table

    d = Descriptor.arel_table
    f = d.project(d[Arel.star]).from(d)

    # Descriptors in the matrix
    f = f.join(c, Arel::Nodes::InnerJoin)
      .on(
        d[:id].eq(c[:descriptor_id]).
        and( c[:observation_matrix_id].eq(observation_matrix_id) )
    ).order(c[:position]).as('a1')

    # TODO: when polymorphic this whole method will collapse and
    # not require this fork
    x = nil
    case row_object_class_name
    when  'Otu'
      x = a[:otu_id].eq(otu_id)
    when 'CollectionObject'
      x = a[:collection_object_id].eq(collection_object_id)
    else
      raise
    end

    # Observations from those descriptros
    b = b.join(f, Arel::Nodes::InnerJoin)
      .on(
        a[:descriptor_id].eq(f[:id]).
        and(x)
    ).as('a2')

    ::Observation.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(t['id']))))
  end

  private

  def otu_and_collection_object_blank
    if otu_id.nil? && collection_object_id.nil?
      errors.add(:base, 'Specify otu OR collection object!')
    end
  end

  def otu_and_collection_object_given
    if !otu_id.nil? && !collection_object_id.nil?
      errors.add(:base, 'Specify otu OR collection object, not both!')
    end
  end
end
