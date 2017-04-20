# Be sure to restart your server when you modify this file.
#
# !! All constants are now composed of Strings only.  They must not reference a class. !!
#
# Contains NOMEN classes of rank/hierarchy in various format.
#

# ICN, ICZN, ICNB class names ordered in an Array
ICN = NomenclaturalRank::Icn.ordered_ranks.map(&:to_s).freeze 
ICZN = NomenclaturalRank::Iczn.ordered_ranks.map(&:to_s).freeze
ICNB = NomenclaturalRank::Icnb.ordered_ranks.map(&:to_s).freeze

# All assignable Rank Classes 
RANKS = ( ['NomenclaturalRank'] + ICN + ICZN + ICNB ).freeze

# ICN Rank Classes in a Hash with keys being the "human" name
# For example, to return the class for a plant family:
#   ::ICN_LOOKUP['family']
ICN_LOOKUP = ICN.inject({}){|hsh, r| hsh.merge!(r.constantize.rank_name => r)}.freeze

#   ::ICNB_LOOKUP['family']
ICNB_LOOKUP = ICNB.inject({}){|hsh, r| hsh.merge!(r.constantize.rank_name => r)}.freeze

# ICZN Rank Classes in a Hash with keys being the "human" name
ICZN_LOOKUP = ICZN.inject({}){|hsh, r| hsh.merge!(r.constantize.rank_name => r)}.freeze

# All ranks, with keys as class strings pointing to common usage
RANKS_LOOKUP = ICN_LOOKUP.invert.merge(ICZN_LOOKUP.invert.merge(ICNB_LOOKUP.invert)).freeze

# An Array of Arrays, used in options for select
#   [["class (ICN)", "NomenclaturalRank::Icn::HigherClassificationGroup::ClassRank"] .. ]
RANKS_SELECT_OPTIONS = RANKS_LOOKUP.collect{|k,v| 
  ["#{v} " + ((k.to_s =~ /Iczn/) ? '(ICZN)' : ((k.to_s =~ /Icnb/) ? '(ICNB)' : '(ICN)') ), k, {class: ((k.to_s =~ /Iczn/) ? :iczn : ((k.to_s =~ /Icnb/) ? :icnb : :icn)) }] }.sort{|a, b| a[0] <=> b[0]}.freeze

# All assignable ranks for family groups, for ICZN, ICN, ICNB
FAMILY_RANK_NAMES_ICZN = NomenclaturalRank::Iczn::FamilyGroup.descendants.map(&:to_s).freeze
FAMILY_RANK_NAMES_ICN = NomenclaturalRank::Icn::FamilyGroup.descendants.map(&:to_s).freeze
FAMILY_RANK_NAMES_ICNB = NomenclaturalRank::Icnb::FamilyGroup.descendants.map(&:to_s).freeze

# All assignable ranks for family group, for ICN, ICNB, and ICZN
FAMILY_RANK_NAMES = ( FAMILY_RANK_NAMES_ICZN + FAMILY_RANK_NAMES_ICN + FAMILY_RANK_NAMES_ICNB ).freeze

# All assignable higher ranks for family group, for ICN, ICNB, and ICZN
HIGHER_RANK_NAMES_ICZN = NomenclaturalRank::Iczn::HigherClassificationGroup.descendants.map(&:to_s).freeze
HIGHER_RANK_NAMES_ICN = NomenclaturalRank::Icn::HigherClassificationGroup.descendants.map(&:to_s).freeze
HIGHER_RANK_NAMES_ICNB = NomenclaturalRank::Icnb::HigherClassificationGroup.descendants.map(&:to_s).freeze

# All assignable ranks for family group and above family names, for ICZN, ICN, ICNB
FAMILY_AND_ABOVE_RANK_NAMES_ICZN = FAMILY_RANK_NAMES_ICZN + HIGHER_RANK_NAMES_ICZN
FAMILY_AND_ABOVE_RANK_NAMES_ICN = FAMILY_RANK_NAMES_ICN + HIGHER_RANK_NAMES_ICN
FAMILY_AND_ABOVE_RANK_NAMES_ICNB = FAMILY_RANK_NAMES_ICNB + HIGHER_RANK_NAMES_ICNB

# All assignable ranks for family group and above family names, for ICN, ICNB, and ICZN
FAMILY_AND_ABOVE_RANK_NAMES = 
  FAMILY_AND_ABOVE_RANK_NAMES_ICZN +
  FAMILY_AND_ABOVE_RANK_NAMES_ICN +
  FAMILY_AND_ABOVE_RANK_NAMES_ICNB 

# Assignable ranks for genus groups
GENUS_RANK_NAMES_ICZN = NomenclaturalRank::Iczn::GenusGroup.descendants.map(&:to_s).freeze
GENUS_RANK_NAMES_ICN = NomenclaturalRank::Icn::GenusGroup.descendants.map(&:to_s).freeze
GENUS_RANK_NAMES_ICNB = NomenclaturalRank::Icnb::GenusGroup.descendants.map(&:to_s).freeze

# All assignable ranks for genus groups, for ICN, ICNB, and ICZN
GENUS_RANK_NAMES = ( GENUS_RANK_NAMES_ICZN + GENUS_RANK_NAMES_ICN + GENUS_RANK_NAMES_ICNB ).freeze

# Assignable ranks for species groups, for ICZN, ICN, ICNB
SPECIES_RANK_NAMES_ICZN = NomenclaturalRank::Iczn::SpeciesGroup.descendants.map(&:to_s).freeze
SPECIES_RANK_NAMES_ICN = NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants.map(&:to_s).freeze
SPECIES_RANK_NAMES_ICNB = NomenclaturalRank::Icnb::SpeciesGroup.descendants.map(&:to_s).freeze

# All assignable ranks for species groups, for ICN, ICNB, and ICZN
SPECIES_RANK_NAMES = ( SPECIES_RANK_NAMES_ICZN + SPECIES_RANK_NAMES_ICN + SPECIES_RANK_NAMES_ICNB ).freeze

# Assignable ranks for genus and species groups
GENUS_AND_SPECIES_RANK_NAMES_ICZN = ( GENUS_RANK_NAMES_ICZN + SPECIES_RANK_NAMES_ICZN ).freeze
GENUS_AND_SPECIES_RANK_NAMES_ICN = ( GENUS_RANK_NAMES_ICN + SPECIES_RANK_NAMES_ICN ).freeze
GENUS_AND_SPECIES_RANK_NAMES_ICNB = ( GENUS_RANK_NAMES_ICNB + SPECIES_RANK_NAMES_ICNB ).freeze

# Assignable ranks for genus and species groups, for ICN, ICNB, and ICZN
GENUS_AND_SPECIES_RANK_NAMES = ( GENUS_RANK_NAMES + SPECIES_RANK_NAMES ).freeze

module RankHelper
  def self.rank_attributes(ranks)
    ranks.inject({}) {|hsh, r| hsh.merge!(r.constantize.rank_name => {rank_class: r, parent: r.constantize.parent_rank.rank_name, name: r.constantize.rank_name })}
  end
end

RANKS_JSON = {
  iczn: {
    higher: RankHelper::rank_attributes(HIGHER_RANK_NAMES_ICZN),
    family: RankHelper::rank_attributes(FAMILY_RANK_NAMES_ICZN),
    genus: RankHelper::rank_attributes(GENUS_RANK_NAMES_ICZN),
    species: RankHelper::rank_attributes(SPECIES_RANK_NAMES_ICZN)
  },
  icn:  {
    higher: RankHelper::rank_attributes(HIGHER_RANK_NAMES_ICN),
    family: RankHelper::rank_attributes(FAMILY_RANK_NAMES_ICN),
    genus: RankHelper::rank_attributes(GENUS_RANK_NAMES_ICN),
    species: RankHelper::rank_attributes(SPECIES_RANK_NAMES_ICN)
  },
  icnb: { 
    higher: RankHelper::rank_attributes(HIGHER_RANK_NAMES_ICNB),
    family: RankHelper::rank_attributes(FAMILY_RANK_NAMES_ICNB),
    genus: RankHelper::rank_attributes(GENUS_RANK_NAMES_ICNB),
    species: RankHelper::rank_attributes(SPECIES_RANK_NAMES_ICNB)
  }
}

# expected parent rank, check for validation purpose
