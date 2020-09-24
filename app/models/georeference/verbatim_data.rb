# The Georeference that is derived exclusively from verbatim_latitude/longitude and  fields in a CollectingEvent.
#
# While it might be concievable that verbatim data are WKT shapes not points, we assume they are for now.
#
#
# !! TODO: presently does not include verbatim_geolocation_uncertainty translation into radius
# !! See https://github.com/SpeciesFileGroup/taxonworks/issues/1770
class Georeference::VerbatimData < Georeference

  # @param [ActionController::Parameters] params
  def initialize(params = {})
    super

    self.is_median_z    = false
    self.is_undefined_z = false # and delta_z is zero, or ignored

    unless collecting_event.nil? || geographic_item
      # value from collecting_event is normalised to meters
      z1 = collecting_event.minimum_elevation
      z2 = collecting_event.maximum_elevation
      if z1.blank?
        # no valid elevation provided
        self.is_undefined_z = true
        delta_z             = 0.0
      else
        # we have at least half of the range data
        # delta_z = z1
        if z2.blank?
          # we have *only* half of the range data
          delta_z = z1
        else
          # we have full range data, so elevation is (top - bottom) / 2
          delta_z = z1 + ((z2 - z1) * 0.5)
          # and show calculated median
          self.is_median_z = true
        end
      end

      point = collecting_event.verbatim_map_center(delta_z) # hmm

      attributes = {point: point}
      attributes[:by] = self.by if self.by

      if point.nil?
        test_grs = []
      else
        test_grs = GeographicItem::Point.where("point = ST_GeographyFromText('POINT(? ? ?)')", point.x, point.y, point.z)
      end

      if test_grs.empty?
        test_grs = [GeographicItem.new(attributes)]
      end

      self.geographic_item = test_grs.first
    end

    # geographic_item
  end


  # @return [Hash]
  #   The interface to DwC for verbatim values only on the CE.
  #   See respective georeferences for other implementations.
  #
  def dwc_georeference_attributes
    { 
      verbatimLatitude: collecting_event.verbatim_latitude,
      verbatimLongitude: collecting_event.verbatim_longitude,

      coordinateUncertaintyInMeters: nil, # See #1770

      decimalLatitude: geographic_item.to_a.first,
      decimalLongitude: geographic_item.to_a.last,

      footprintWKT: geographic_item.geo_object.to_s,

      georeferenceSources: "Physical collection object.",
      georeferenceRemarks: "Derived from a instance of TaxonWorks' Georeference::VerbatimData.",
      georeferenceProtocol: 'A geospatial point translated from verbatim values recorded on human-readable media (e.g. paper specimen label, field notebook).',
      geodeticDatum: verbatim_datum,
      georeferenceVerificationStatus: confidences&.collect{|c| c.name}.join('; '), 

      georeferencedBy: created_by.name,
      georeferencedDate: created_at
    }
  end

end
