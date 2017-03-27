class TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Legitimate::NomenNovum < TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Legitimate

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000089'

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Legitimate)
  end

  def self.gbif_status
    'novum'
  end

end
