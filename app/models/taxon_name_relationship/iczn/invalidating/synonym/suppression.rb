class TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression < TaxonNameRelationship::Iczn::Invalidating::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000280'

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective)
  end

  def subject_properties
    [ TaxonNameClassification::Iczn::Unavailable::Suppressed ]
  end

  def object_status
    'conserved'
  end

  def subject_status
    'suppressed'
  end

  def self.gbif_status_of_subject
    'rejiciendum'
  end

  def self.gbif_status_of_object
    'conservandum'
  end

  def self.nomenclatural_priority
    :reverse
  end

  def self.assignment_method
    # bus.set_as_iczn_suppression_of(aus)
    :iczn_set_as_suppression_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_suppression = bus
    :iczn_suppression
  end

end
