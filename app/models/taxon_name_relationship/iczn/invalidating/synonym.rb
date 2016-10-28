class TaxonNameRelationship::Iczn::Invalidating::Synonym < TaxonNameRelationship::Iczn::Invalidating

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000276'

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Iczn::Invalidating::Usage) +
            [TaxonNameRelationship::Iczn::Invalidating.to_s]
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Available::Invalid)
  end

  def object_properties
    [ TaxonNameClassification::Iczn::Invalid ]
  end

  def object_status
    'senior synonym'
  end

  def subject_status
    'synonym'
  end

  def self.assignment_method
    # bus.set_as_iczn_synonym_of(aus)
    :iczn_set_as_synonym_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_synonym = bus
    :iczn_synonym
  end

end
