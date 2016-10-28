class TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation < TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000278'

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName)
  end

  def object_status
    'correct original spelling'
  end

  def subject_status
    'unjustified emendation'
  end

  def self.assignment_method
    # bus.set_as_iczn_unjustified_emendation_of(aus)
    :iczn_set_as_unjustified_emendation_of
  end

  def self.inverse_assignment_method
    # aus.iczn_unjustified_emendation = bus
    :iczn_unjustified_emendation
  end

end
