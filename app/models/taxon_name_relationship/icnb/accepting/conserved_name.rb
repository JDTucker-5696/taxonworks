class TaxonNameRelationship::Icnb::Accepting::ConservedName < TaxonNameRelationship::Icnb::Accepting

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000095'

  def self.assignable
    true
  end

  def object_status
    'rejected'
  end

  def subject_status
    'conserved'
  end

  def self.gbif_status_of_subject
    'conservandum'
  end

  def self.gbif_status_of_object
    'rejiciendum'
  end

  def self.nomenclatural_priority
    :reverse
  end

  def self.assignment_method
    # bus.set_as_icn_conserved_name_of(aus)
    :icnb_set_as_conserved_name_of
  end

  def self.inverse_assignment_method
    # aus.icn_conserved_name = bus
    :icnb_conserved_name
  end

end
