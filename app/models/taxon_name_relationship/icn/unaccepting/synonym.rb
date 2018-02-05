class TaxonNameRelationship::Icn::Unaccepting::Synonym < TaxonNameRelationship::Icn::Unaccepting

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000372'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting) +
        self.collect_descendants_to_s(TaxonNameRelationship::Icn::Unaccepting::Usage)
  end

  def subject_properties
    [ TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate ]
  end

  def object_status
    'synonym'
  end

  def subject_status
    'junior synonym'
  end

  def self.assignment_method
    # bus.set_as_icn_synonym_of(aus)
    :icn_set_as_synonym_of
  end

  def self.inverse_assignment_method
    # aus.icn_synonym = bus
    :icn_synonym
  end

end