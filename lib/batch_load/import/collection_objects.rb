module BatchLoad
  # TODO: Originally transliterated from Import::AssertedDistributions: Remove this to-do after successful operation.
  class Import::CollectionObjects < BatchLoad::Import

    attr_accessor :collection_objects

    attr_accessor :namespace

    def initialize(**args)
      @collection_objects = {}
      super(args)
    end

    # process each row for information:
    def build_collection_objects
      i       = 1 # accounting for headers
      # identifier namespace
      header1 = csv.headers[0] # should be 'collection_object_identifier_namespace_short_name'
      header2 = csv.headers[1] # should be 'collection_object_identifier_identifier'
      header5 = csv.headers[5] # should be 'collecting_event_identifier_namespace_short_name'
      header6 = csv.headers[6] # should be 'collecting_event_identifier_identifier'
      header7 = csv.headers[7] # should be 'collecting_event_identifier_type'
      csv.each do |row|
        co_namespace = row[header1]
        co_id        = row[header2]
        next if (co_namespace.nil? or co_id.nil?) # no namespace to search!
        # find a namespace (ns1) with a short_name of row[headers[0]] (id1)
        # find a collection_object which has an identifier which has a namespace (ns1), and a cached of
        # (ns1.short_name + ' ' + identifier.identifier)
        # ns1    = Namespace.where(short_name: id1).first
        long         = row['longitude'] # longitude
        lat          = row['latitude'] # latitude
        method       = row['method']
        error        = (row['error'].to_s + ' ' + row['georeference_error_units'].to_s).strip
        ce_namespace = row[header5]
        pale         = row['date']
        co           = CollectionObject.joins(:identifiers).where(identifiers: {cached: "#{co_namespace} #{co_id}"}).first
        otu          = Otu.find_or_create_by(name: row['otu'])
        td           = TaxonDetermination.find_or_create_by(otu:                          otu,
                                                            biological_collection_object: co)
        ce           = CollectingEvent.find_or_create_by(verbatim_locality:                row['verbatim_location'],
                                                         verbatim_geolocation_uncertainty: error,
                                                         verbatim_date:                    row['date'],
                                                         start_date_day:                   row['day'],
                                                         start_date_month:                 row['month'],
                                                         start_date_year:                  row['year'],
                                                         verbatim_longitude:               long,
                                                         verbatim_latitude:                lat,
                                                         verbatim_method:                  method)
        ce.save!
        case method.downcase
          when 'geolocate'
            # faking a Georeference::GeoLocate:
            #   1) create the Georeference, using the newly created collecting_event
            gr                 = Georeference::GeoLocate.create(collecting_event: ce)
            #   2) build a fake iframe response in the form '52.65|-106.333333|3036|Unavailable'
            text               = "#{lat}|#{long}|#{Utilities::Geo.elevation_in_meters(error)}|Unavailable"
            #   3) use that fake to stimulate the parser to create the object
            gr.iframe_response = text
            gr.save
          else
            # nothing to do?
        end unless method.nil?

        ns_ce = Namespace.where(short_name: ce_namespace).first
        ce_id = Identifier.new(namespace:  ns_ce,
                               type:       'Identifier::' + row[header7],
                               identifier: row[header6])
        ce.identifiers << ce_id
        co.collecting_event = ce
        # error_radius:     Utilities::Geo.elevation_in_meters(row['error']))
        # ident = Identifier.find_or_create_by(identifier:   row[0],
        #                                      namespace_id: n_s.id,
        #                                      type:         'Identifier::Local::Import',
        # )

        i                   += 1
      end
      @total_lines = i - 1
    end

    def build
      if valid?
        build_collection_objects
        @processed = true
      end
    end
  end
end

