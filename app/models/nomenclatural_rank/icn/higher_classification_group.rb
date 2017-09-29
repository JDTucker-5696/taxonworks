class NomenclaturalRank::Icn::HigherClassificationGroup < NomenclaturalRank::Icn

  def self.validate_name_format(taxon_name)
    if taxon_name.present?
      taxon_name.errors.add(:name, 'must be capitalized') unless taxon_name.name == taxon_name.name.capitalize
      taxon_name.errors.add(:name, 'must be at least two letters') unless taxon_name.name.length > 1
    end
  end

  def self.valid_parents
    self.collect_descendants_to_s(
        NomenclaturalRank::Icn::HigherClassificationGroup)
  end

end
