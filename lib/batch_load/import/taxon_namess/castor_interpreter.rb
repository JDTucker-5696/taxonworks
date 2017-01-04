# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::TaxonNamess::CastorInterpreter < BatchLoad::Import

    # The parent for the top level names
    attr_accessor :parent_taxon_name

    # The id of the parent taxon name, computed automatically as Root if not provided
    attr_accessor :parent_taxon_name_id

    # The code (Rank Class) that new names will use
    attr_accessor :nomenclature_code

    # Whether to create an OTU as well
    attr_accessor :also_create_otu

    # Required to handle some defaults
    attr_accessor :project_id

    def initialize(nomenclature_code: nil, parent_taxon_name_id: nil, also_create_otu: false, **args)
      @nomenclature_code = nomenclature_code
      @parent_taxon_name_id = parent_taxon_name_id
      @also_create_otu = also_create_otu

      super(args)
    end
    
    def parent_taxon_name 
      Project.find(@project_id).root_taxon_name
    end
    
    def parent_taxon_name_id
      parent_taxon_name.id
    end

    def build_taxon_names
      @total_data_lines = 0
      i = 0

      namespace_castor = Namespace.find_by(name: "Castor")
      taxon_names = {}

      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:taxon_name] = []
        parse_result.objects[:taxon_name_relationship] = []

        @processed_rows[i] = parse_result

        begin
          next if row['rank'] == "complex"
          next if row['rank'] == "species group"
          next if row['rank'] == "series"
          next if row['taxon_name'] == "unidentified"
      
          taxon_name_identifier_castor_text = row["guid"]
          taxon_name_identifier_castor = { namespace: namespace_castor,
                                           type: "Identifier::Local::TaxonConcept",
                                           identifier: taxon_name_identifier_castor_text
          }

          taxon_name_identifiers = []
          taxon_name_identifiers.push(taxon_name_identifier_castor) if !taxon_name_identifier_castor_text.blank?

          protonym_attributes = {
            name: row['taxon_name'],
            year_of_publication: year_of_publication(row['author_year']),
            rank_class: Ranks.lookup(@nomenclature_code.to_sym, row['rank']),
            by: @user,
            also_create_otu: @also_create_otu,
            project: @project,
            verbatim_author: verbatim_author(row['author_year']),
            taxon_name_authors_attributes: taxon_name_authors_attributes(verbatim_author(row['author_year'])),
            identifiers_attributes: taxon_name_identifiers
          }

          p = Protonym.new(protonym_attributes)
          taxon_name_id = row['id']
          parent_taxon_name_id = row['parent_id']
          taxon_names[taxon_name_id] = p

          if taxon_names[parent_taxon_name_id].nil?
            p.parent = parent_taxon_name
          else
            p.parent = taxon_names[parent_taxon_name_id]
          end
          
          parse_result.objects[:taxon_name].push p
          @total_data_lines += 1 if p.present?

          # TaxonNameRelationship
          related_name_id = row['related_name_id']

          if !taxon_names[related_name_id].nil?
            related_name_nomen_class = nil

            begin
              related_name_nomen_class = row['related_name_nomen_class'].constantize

              if related_name_nomen_class.ancestors.include?(TaxonNameRelationship)
                taxon_name_relationship = related_name_nomen_class.new(subject_taxon_name: p, object_taxon_name: taxon_names[related_name_id])
                parse_result.objects[:taxon_name_relationship].push taxon_name_relationship
              end
            rescue NameError
            end
          end

          # TaxonNameClassification
          name_nomen_classification = row['name_nomen_classification']
          p.taxon_name_classifications.new(type: name_nomen_classification) if TaxonName::EXCEPTED_FORM_TAXON_NAME_CLASSIFICATIONS.include?(name_nomen_classification)
        end
      end

      @total_lines = i
    end

    def build
      if valid?
        build_taxon_names
        @processed = true
      end
    end

    private

    def year_of_publication(author_year)
      split_author_year = author_year.split(" ")
      year = split_author_year[split_author_year.length - 1]
      year =~ /\A\d+\z/ ? year : ""
    end

    def verbatim_author(author_year)
      author_end_index = author_year.rindex(" ") 
      author_end_index ||= author_year.length
      author_year[0...author_end_index]
    end

    def taxon_name_authors_attributes(author_info)
      multiple_author_query = "and"
      multiple_author_index = author_info.index(multiple_author_query)
      split_author_info = multiple_author_index.nil? ? [author_info] : author_info.split(multiple_author_query)
      author_infos = []

      split_author_info.each do |author_str|
        author_infos.push(author_info(author_str)) if author_str != "NA" && author_str != "unpublished"
      end

      author_infos
    end

    def author_info(author_string)
      seperator_query = " "
      separator_index = author_string.index(seperator_query)

      last_name = author_string
      first_name = ""

      if !separator_index.nil?
        separator_index += seperator_query.length
        split_author_info = author_string.split(seperator_query)
        last_name = split_author_info[0]
        first_name = split_author_info[1] 
      end

      { last_name: last_name, first_name: first_name, suffix: "suffix" }
    end
  end
end
