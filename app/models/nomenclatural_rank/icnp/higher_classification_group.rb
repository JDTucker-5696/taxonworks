class NomenclaturalRank::Icnp::HigherClassificationGroup < NomenclaturalRank::Icnp

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'must be capitalized') unless  !taxon_name.name.blank? && taxon_name.name == taxon_name.name.capitalize
    taxon_name.errors.add(:name, 'must be at least two letters') unless taxon_name.name.length > 1
  end

  def self.valid_parents
    self.collect_descendants_to_s(
        NomenclaturalRank::Icnp::HigherClassificationGroup)
  end

end
