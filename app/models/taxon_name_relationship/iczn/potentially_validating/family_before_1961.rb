class TaxonNameRelationship::Iczn::PotentiallyValidating::FamilyBefore1961 < TaxonNameRelationship::Iczn::PotentiallyValidating

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000042'

  # left_side
  def self.valid_subject_ranks
    FAMILY_RANK_NAMES_ICZN
  end

  # right_side
  def self.valid_object_ranks
    FAMILY_RANK_NAMES_ICZN
  end

  def object_status
    'family name based on genus synonym replaced before 1961'
  end

  def subject_status
    'as family name based on genus synonym replaced before 1961'
  end

  def self.nomenclatural_priority
    :direct
  end

  def self.assignment_method
    # bus.set_as_iczn_family_before_1961_of(aus)
    :iczn_set_as_family_before_1961_of
  end

  # as.
  def self.inverse_assignment_method
    # Aidae.iczn_family_before_1961 = Bidae
    :iczn_family_before_1961
  end

  def self.assignable
    true
  end

end