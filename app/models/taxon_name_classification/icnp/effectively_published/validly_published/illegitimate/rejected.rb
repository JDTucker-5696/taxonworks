class TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Illegitimate::Rejected < TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Illegitimate

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000104'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Illegitimate,
        TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Illegitimate::NotInOfficialList,
        TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Illegitimate::Homonym)
  end

  def self.gbif_status
    'rejiciendum'
  end

  def sv_not_specific_classes
    true
  end
end