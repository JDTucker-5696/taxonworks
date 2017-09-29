class TaxonNameClassification::Latinized::PartOfSpeech::Participle < TaxonNameClassification::Latinized::PartOfSpeech

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000053'

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Latinized::PartOfSpeech::NounInApposition,
                                                 TaxonNameClassification::Latinized::PartOfSpeech::NounInGenitiveCase,
                                                 TaxonNameClassification::Latinized::PartOfSpeech::Adjective)
  end

  def self.assignable
    true
  end

  def set_cached 
    set_gender_in_taxon_name
    super
  end

end
