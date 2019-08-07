module BatchLoad
  class Import::TaxonNames::DwcaChecklistInterpreter < BatchLoad::Import
    CLASSIFICATION_NAMES = [
      'infraspecificepithet', 'specificepithet',
      'subgenus', 'genus',
      'scientificname']

    # @param [Hash] args
    def initialize(nomenclature_code: nil, dwca_namespace: nil, **args)
      @nomenclature_code = nomenclature_code
      @dwca_namespace = Namespace.find_by_short_name(dwca_namespace) if dwca_namespace
      @taxon_names = {}
      super(args)
    end

    ## CANADENSYS DATASET: ranks set by term (all terms before a given term are null/blank)
    # infraspecificEpithet: ['subspecies', 'variety']
    # specificEpithet: ['species', 'subspecies', 'variety'] # Last two were not expected. Dataset error? All 6 cases are synonyms
    # subgenus: ['section', 'series', 'subgenus', 'subsection'] # WARNING: Only when rank=='subgenus' name can be extracted out from this term
    # genus: ['family', 'genus', 'section', 'series', 'subsection', 'tribe']
    #         WARNING: Only when rank=='genus' name can be extracted out from this term
    #         'tribe' unexpected. Only 2 cases both synonyms.
    #         'family' unexpected. Only 7 cases all synonyms.

    def _build_taxon_names(records, parent)
      records.each do |record|
        begin
          next if record[:row]['taxonrank'] == 'superorder' # Rank doesn't exists in TW for ICN

          name = verbatim_name = record[:row]['scientificname'].chomp(record[:row]['scientificnameauthorship']).strip

          case record[:row]['taxonrank']
            when 'species', 'subspecies', 'variety', 'genus'
              name = record[:row][CLASSIFICATION_NAMES.detect { |x| !record[:row][x].blank? }]
            when 'subgenus'
              name = record[:row]['subgenus']
              name = $1 if (name =~ /^\(([^)]*)\)$/ || name =~ /\s+subg(?:en)?(?:us)?(?:\.|\s)\s*(.*)/)
            when 'series'
              name = $1 if verbatim_name =~ /\s+ser(?:ies)?(?:\.|\s)\s*(.*)/
            when 'section', 'subsection'
              name = $1 if verbatim_name =~ /\s+(?:sub)?sect?(?:ion)?(?:\.|\s)\s*(.*)/
          end

          is_hybrid = (verbatim_name =~ /×/)

          # Skip hybrid names that are not simple
          next if is_hybrid && (name !~ /^\s*×\s*[^\s×]+\s*$/)
          next if 2 < CLASSIFICATION_NAMES.inject(0) { |c, f| c + (/×/ =~ record[:row][f] ? 1 : 0) }

          protonym_attributes = {
            name: name,
            verbatim_name: record[:row]['scientificname'],
            parent: parent,
            rank_class: Ranks.lookup(@nomenclature_code.to_sym, record[:row]['taxonrank']),
            by: @user,
            also_create_otu: false,
            project: @project,
            verbatim_author: record[:row]['scientificnameauthorship']
          }
          protonym_attributes[:year_of_publication] = $1 if /(\s\d{4})(?!.*\d+)/ =~ protonym_attributes[:verbatim_author]
          protonym_attributes[:name].gsub!('×', '')

          parse_result = BatchLoad::RowParse.new

          name = Protonym.new(protonym_attributes)
          name.taxon_name_classifications.build(type: TaxonNameClassification::Icn::Hybrid) if is_hybrid

          record[:taxon_name] = name
          parse_result.objects[:taxon_name] = [name]

          if @dwca_namespace
            name.identifiers.new(
              type: Identifier::Local::Import,
              namespace: @dwca_namespace,
              identifier: record[:row]['id']
            )
          end

          @processed_rows[record[:rowno]] = parse_result
          record[:parse_result] = parse_result

          @total_data_lines += 1

          _build_taxon_names(record[:children], name)
        end
      end
    end

    def build_taxon_names
      @total_data_lines = 0
      i = 0

      # build records tree
      records = {}
      csv.each do |row|
        i += 1
        raise "Duplicated taxonID #{row["taxonid"]}." unless records[row["taxonid"]].nil?
        # Build records LUT
        records[row["taxonid"]] = { row: row, rowno: i, children: [] }
      end

      records.each do |k, v|
        if not v[:row]["parentnameusageid"].blank?
          if records[v[:row]["parentnameusageid"]].nil?
            raise "Invalid parentNameUsageID #{v[:row]["parentnameusageid"]} points to no record within this dataset."
          end

          parent = records[v[:row]["parentnameusageid"]]

          parent = records[parent[:row]["parentnameusageid"]] if parent[:row]["taxonrank"] == "superorder"

          parent[:children] << v
          v[:parent] = parent
        end
      end

      roots = records.values.select { |v| v[:row]["parentnameusageid"].blank? }

      # loop through rows

      _build_taxon_names(roots, Project.find(@project_id).root_taxon_name)

      # WORKS WHEN PREVIEWING ONLY, BUT CRASHES WITH NULL CONTRAINT VIOLATION WHEN CREATING
      # records.each do |k, record|
      #   parse_result = record[:parse_result]

      #   unless parse_result.nil?
      #     parse_result.objects[:taxon_name_relationship] = []

      #     record[:row]['hybrid parent of'].strip.split('|').each do |p|
      #       parse_result.objects[:taxon_name_relationship] << TaxonNameRelationship::Hybrid.new(
      #         subject_taxon_name: records[p][:taxon_name],
      #         object_taxon_name: record[:taxon_name]
      #       )
      #     end
      #   end
      # end

      @total_lines = i
    end

    def build
      if valid?
        build_taxon_names
        @processed = true
      end
    end
  end
end
