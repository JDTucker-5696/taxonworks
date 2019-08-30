module ObservationMatrices::Export::NexmlHelper

  def nexml_descriptors(options = {})
    opt = {target: ''}.merge!(options)
    xml = Builder::XmlMarkup.new(target: opt[:target])
    m = opt[:observation_matrix]

    # Multistate characters
    xml.characters(
      id: "multistate_character_block_#{m.id}",
      otus: "otu_block_#{m.id}", 
      'xsi:type' => 'nex:StandardCells', 
      label:  "Multistate characters for matrix #{m.name}"
    ) do

      descriptors = m.symbol_descriptors.load
      xml.format do
        
        descriptors.each do |c|
          xml.states(id: "states_for_chr_#{c.id}") do
            if c.qualitative?

              c.character_states.each_with_index do |cs,i|
                xml.state(id: "cs#{cs.id}", label: cs.name, symbol: "#{i}") 
              end

              # Add a missing state for each character regardless of whether we use it or not
              xml.state(id: "missing#{c.id}", symbol: c.character_states.size, label: "?")

              # Poll the matrix for polymorphic/uncertain states
              uncertain = m.polymorphic_cells_for_descriptor(descriptor_id: c.id, symbol_start: c.character_states.size + 1)

              uncertain.keys.each do |pc|
                xml.uncertain_state_set(id: "cs#{c.id}unc_#{uncertain[pc].sort.join}", symbol: pc) do |uss|
                  uncertain[pc].collect{|m| xml.member(state: "cs#{m}") }
                end
              end
            elsif c.presence_absence?
         
         
            end # end states block
          
          end
        end  # end character loop for multistate states 




        descriptors.collect{|c| xml.char(id: "c#{c.id}", states: "states_for_chr_#{c.id}", label: c.name)}

      end # end format
      include_multistate_matrix(opt.merge(descriptors: descriptors)) if opt[:include_matrix] 
    end # end characters

    d = m.continuous_descriptors.order('observation_matrix_columns.position').load
    # continuous characters
    xml.characters(
      id: "continuous_character_block_#{m.id}",
      otus: "otu_block_#{m.id}",
      'xsi:type' => 'nex:ContinuousCells',
      label: "Continuous characters for matrix #{m.name}") do
        xml.format do
          d.collect{|c| xml.char(id: "c#{c.id}", label: c.name)}
        end # end format

        include_continuous_matrix(opt.merge(descriptors: d)) if opt[:include_matrix] 
      end # end multistate characters
      opt[:target]
  end


  def include_multistate_matrix(options = {})
    opt = {target: '', descriptors: []}.merge!(options)
    xml = Builder::XmlMarkup.new(target: opt[:target])

    m = opt[:observation_matrix]

    # the matrix 
    cells = m.observations_in_grid({})[:grid]

    p = opt[:descriptors].map(&:id)
    q = m.observation_matrix_rows.order('observation_matrix_rows.position').collect{|i| i.row_object.to_global_id }

    xml.matrix do
      m.observation_matrix_rows.each do |r|
        xml.row(id: "multistate_row#{r.id}", otu: "row_#{r.id}") do |row| # use row_id to uniquel identify the row ##  Otu#id to uniquely id the row

          # cell representation
          opt[:descriptors].each do |d|

          #  byebug if d.id == 37
            x = p.index(d.id) # opt[:descriptors].index(d)  #   .index(d)
            y = q.index(r.row_object.to_global_id)

            observations = cells[ x  ][ y ]

            case observations.size
            when 0 
              state = "missing#{d.id}"
            when 1
              state = "cs#{observations[0].character_state_id}"
            else # > 1 
              state = "cs#{d.id}unc_#{observations.collect{|i| i.character_state_id}.sort.join}" # should just unify identifiers with above.
            end

            #byebug if state == 'cs' # d.id == 37 

            xml.cell(char: "c#{d.id}", state: state)
          end
        end # end the row
      end # end OTUs
    end # end matrix

    opt[:target]
  end

  def include_continuous_matrix(options = {})
    opt = {target:  '', descriptors: []}.merge!(options)
    xml = Builder::XmlMarkup.new(target: opt[:target])
    m = opt[:observation_matrix]

    # the matrix 
    cells = m.observations_in_grid({})[:grid]

    z = m.observation_matrix_rows.map.collect{|i| i.row_object.to_global_id}

    xml.matrix do |mx|
      m.observation_matrix_rows.each do |o|
        xml.row(id: "continuous_row#{o.id}", otu: "row_#{o.id}") do |r| # use Otu#id to uniquely id the row

          # cell representation
          opt[:descriptors].each do |c|

            x = m.descriptors.index(c)
            y = z.index(o.row_object.to_global_id)

            observations = cells[ x ][ y ]
            if observations.size > 0  && !observations.first.continuous_value.nil?
              xml.cell(char: "c#{c.id}", state: observations.first.continuous_value)
            end
          end
        end # end the row
      end # end OTUs
    end # end matrix
    return opt[:target]
  end

  def nexml_otus(options = {})
    opt = {target: ''}.merge!(options)
    xml = Builder::XmlMarkup.new(target: opt[:target])
    m = opt[:observation_matrix]

    xml.otus(
      id: "otu_block_#{m.id}",
      label: "Otus for matrix #{m.name}"
    ) do
      m.observation_matrix_rows.each do |r|
        xml.otu(
          id: "row_#{r.id}",
          about: "#row_#{r.id}", # technically only need this for proper RDFa extraction  !!! Might need this to be different, is it about row, or row object!
          label: observation_matrix_row_label(r)
        ) do
          include_collection_objects(opt.merge(otu: r.row_object)) if opt[:include_collection_objects]
        end
      end
    end 
    return opt[:target]
  end

  def include_collection_objects(options = {})
    opt = {target: ''}.merge!(options)
    xml = Builder::XmlMarkup.new(target: opt[:target])
    otu = opt[:otu] 

    # otu.collection_objects.with_identifiers.each do |s|
    otu.current_collection_objects.each do |s|
      xml.meta('xsi:type' => 'ResourceMeta', 'rel' => 'dwc:individualID') do
        if a = s.preferred_catalog_number
          xml.meta(a.namespace.name, 'xsi:type' => 'LiteralMeta', 'property' => 'dwc:collectionID') 
          xml.meta(a.identifier, 'xsi:type' => 'LiteralMeta', 'property' => 'dwc:catalogNumber') 
        else
          xml.meta('UNDEFINED', 'xsi:type' => 'LiteralMeta', 'property' => 'dwc:collectionID') 
          xml.meta(s.id, 'xsi:type' => 'LiteralMeta', 'property' => 'dwc:catalogNumber') 
        end
      end
    end # end specimens

    return opt[:target]
  end
end
