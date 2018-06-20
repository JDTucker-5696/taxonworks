class TaxonNameRelationship::Iczn < TaxonNameRelationship

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000233'.freeze

  validates_uniqueness_of :subject_taxon_name_id, scope: [:type, :object_taxon_name_id]

  # left_side
  def self.valid_subject_ranks
    ::ICZN #FAMILY_RANK_NAMES_ICZN + GENUS_AND_SPECIES_RANK_NAMES_ICZN
  end

  # right_side
  def self.valid_object_ranks
    ::ICZN #FAMILY_RANK_NAMES_ICZN + GENUS_AND_SPECIES_RANK_NAMES_ICZN
  end

  def self.disjoint_subject_classes
    ICN_TAXON_NAME_CLASSIFICATION_NAMES + ICNB_TAXON_NAME_CLASSIFICATION_NAMES + ICTV_TAXON_NAME_CLASSIFICATION_NAMES
  end

  def self.disjoint_object_classes
    ICN_TAXON_NAME_CLASSIFICATION_NAMES + ICNB_TAXON_NAME_CLASSIFICATION_NAMES +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Unavailable)
  end

end
