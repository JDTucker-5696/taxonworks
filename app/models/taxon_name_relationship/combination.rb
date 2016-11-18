class TaxonNameRelationship::Combination < TaxonNameRelationship

  # Abstract class.
  validates_uniqueness_of :object_taxon_name_id, scope: :type

  def validate_subject_is_protonym
    errors.add(:subject_taxon_name, 'Must be a protonym') if subject_taxon_name.type == 'Combination'
  end

  def self.order_index
    RANKS.index(::ICN_LOOKUP[self.name.demodulize.underscore.humanize.downcase])
  end

  def self.disjoint_classes
    self.collect_descendants_to_s(TaxonNameClassification)
  end

  def self.disjoint_subject_classes
    self.disjoint_classes
  end

  def self.disjoint_object_classes
    self.disjoint_classes
  end

  def self.nomenclatural_priority
    :reverse
  end

end
