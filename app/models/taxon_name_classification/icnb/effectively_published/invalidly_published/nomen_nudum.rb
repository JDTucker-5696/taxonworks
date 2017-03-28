class TaxonNameClassification::Icnb::EffectivelyPublished::InvalidlyPublished::NomenNudum < TaxonNameClassification::Icnb::EffectivelyPublished::InvalidlyPublished

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000090'

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icnb::EffectivelyPublished::InvalidlyPublished)
  end

  def self.gbif_status
    'nudum'
  end

end
