class TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished::NomenNudum < TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000379'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished)
  end

  def self.gbif_status
    'nudum'
  end

  def sv_not_specific_classes
    true
  end
end
