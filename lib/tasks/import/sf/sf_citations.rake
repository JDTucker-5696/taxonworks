# rake tw:db:restore backup_directory=/Users/proceps/src/sf/import/onedb2tw/snapshots/15_after_scrutinies/ file=localhost_2018-09-26_212447UTC.dump

namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :citations do

        desc 'time rake tw:project_import:sf_import:citations:create_otu_cites user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define create_otu_cites: [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating citations for OTUs...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          # get_tw_project_id = get('SFFileIDToTWProjectID')
          # get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID') # Note this is an OTU associated with a SF.TaxonNameID (probably a bad taxon name)
          # get_taxon_name_otu_id = import.get('TWTaxonNameIDToOtuID') # Note this is the OTU offically associated with a real TW.taxon_name_id
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          # get_nomenclator_string = import.get('SFNomenclatorIDToSFNomenclatorString')
          get_nomenclator_metadata = import.get('SFNomenclatorIDToSFNomenclatorMetadata')
          get_cvt_id = import.get('CvtProjUriID')
          # get_containing_source_id = import.get('TWSourceIDToContainingSourceID') # use to determine if taxon_name_author must be created (orig desc only)
          # get_sf_taxon_name_authors = import.get('SFRefIDToTaxonNameAuthors') # contains ordered array of SF.PersonIDs

          path = @args[:data_directory] + 'tblCites.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          # tblCites columns: TaxonNameID, SeqNum, RefID, CitePages, Note, NomenclatorID, NewNameStatusID, TypeInfoID, ConceptChangeID, CurrentConcept, InfoFlags, InfoFlagStatus, PolynomialStatus, [housekeeping]
          #   Handle: TaxonNameID, RefID, CitePages, Note, NomenclatorID (verbatim), NewNameStatus(ID), TypeInfo(ID), InfoFlags, InfoFlagStatus, [housekeeping]
          #   Do not handle: Seqnum, ConceptChangeID, CurrentConcept, PolynomialStatus


          count_found = 0
          error_counter = 0
          # no_taxon_counter = 0
          cite_found_counter = 0
          # otu_not_found_counter = 0
          orig_desc_source_id = 0 # make sure only first cite to original description is handled as such (when more than one cite to same source)
          # otu_only_counter = 0

          base_uri = 'http://speciesfile.org/legacy/'

          file.each_with_index do |row, i|
            sf_taxon_name_id = row['TaxonNameID']
            next unless get_tw_otu_id.has_key?(sf_taxon_name_id)

            sf_ref_id = row['RefID']
            source_id = get_tw_source_id[sf_ref_id].to_i
            next if source_id == 0

            otu = Otu.find(get_tw_otu_id[sf_taxon_name_id]) # need otu object for project_id and
            project_id = otu.project_id.to_s

#            logger.info "Working with TW.project_id: #{project_id}, SF.TaxonNameID #{sf_taxon_name_id} = TW.otu_id #{otu.id},
#        SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']} (count #{count_found += 1}) \n"

            #cite_pages = row['CitePages']

            new_name_uri = (base_uri + 'new_name_status/' + row['NewNameStatusID']) unless row['NewNameStatusID'] == '0'
            type_info_uri = (base_uri + 'type_info/' + row['TypeInfoID']) unless row['TypeInfoID'] == '0'
            info_flag_status_uri = (base_uri + 'info_flag_status/' + row['InfoFlagStatus']) unless row['InfoFlagStatus'] == '0'

            new_name_cvt_id = get_cvt_id[project_id][new_name_uri]
            type_info_cvt_id = get_cvt_id[project_id][type_info_uri]
            info_flag_status_cvt_id = get_cvt_id[project_id][info_flag_status_uri]

            info_flags = row['InfoFlags'].to_i
            citation_topics_attributes = []

            if info_flags > 0
              base_cite_info_flags_uri = (base_uri + 'cite_info_flags/') # + bit_position below
              cite_info_flags_array = Utilities::Numbers.get_bits(info_flags)

              citation_topics_attributes = cite_info_flags_array.collect {|bit_position|
                {topic_id: get_cvt_id[project_id][base_cite_info_flags_uri + bit_position.to_s],
                 project_id: project_id,
                 created_at: row['CreatedOn'],
                 updated_at: row['LastUpdate'],
                 created_by_id: get_tw_user_id[row['CreatedBy']],
                 updated_by_id: get_tw_user_id[row['ModifiedBy']]
                }
              }
            end

            # citation_topics_attributes ||= [] # or or equals

            metadata = {
                ## Note: Add as attribute before save citation
                notes_attributes: [{text: row['Note'], # (row['Note'].blank? ? nil :   rejected automatically by notable
                                    project_id: project_id,
                                    created_at: row['CreatedOn'],
                                    updated_at: row['LastUpdate'],
                                    created_by_id: get_tw_user_id[row['CreatedBy']],
                                    updated_by_id: get_tw_user_id[row['ModifiedBy']]}],

                ## NewNameStatus: As tags to citations, create 16 keywords for each project, set up in case statement; test for NewNameStatusID > 0
                ## TypeInfo: As tags to citations, create n keywords for each project, set up in case statement (2364 cases!)
                # tags_attributes: [
                #     #  {keyword_id: (row['NewNameStatus'].to_i > 0 ?
                # ControlledVocabularyTerm.where('uri LIKE ? and project_id = ?', "%/new_name_status/#{row['NewNameStatusID']}", project_id).limit(1).pluck(:id).first : nil), project_id: project_id},
                #     #  {keyword_id: (row['TypeInfoID'].to_i > 0 ? ControlledVocabularyTerm.where('uri LIKE ? and project_id = ?', "%/type_info/#{row['TypeInfoID']}", project_id).limit(1).pluck(:id).first : nil), project_id: project_id}
                #     {keyword_id: (new_name_uri ? new_name_cvt_id : nil), project_id: project_id},
                #     {keyword_id: (type_info_uri ? Keyword.where('uri = ? AND project_id = ?', type_info_uri, project_id).limit(1).pluck(:id).first : nil), project_id: project_id}
                #
                # ],

                tags_attributes: [{keyword_id: new_name_cvt_id, project_id: project_id}, {keyword_id: type_info_cvt_id, project_id: project_id}],

                ## InfoFlagStatus: Add confidence, 1 = partial data or needs review, 2 = complete data
                confidences_attributes: [{confidence_level_id: info_flag_status_cvt_id, project_id: project_id}],
                citation_topics_attributes: citation_topics_attributes
            }

            # byebug

            citation = Citation.new(
                metadata.merge(
                    source_id: source_id,
                    pages: row['CitePages'],
                    # is_original: (row['SeqNum'] == '1' ? true : false),
                    citation_object: otu,

                    # housekeeping for citation
                    project_id: project_id,
                    created_at: row['CreatedOn'],
                    updated_at: row['LastUpdate'],
                    created_by_id: get_tw_user_id[row['CreatedBy']],
                    updated_by_id: get_tw_user_id[row['ModifiedBy']]
                )
            )

            begin
              citation.save!
            rescue ActiveRecord::RecordInvalid # citation not valid

              # yes I know this is ugly but it works
              if citation.errors.messages[:source_id].nil?
                logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id},
SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                next
              else # make pages unique and save again
                if citation.errors.messages[:source_id].include?('has already been taken') # citation.errors.messages[:source_id][0] == 'has already been taken'
                  citation.pages = "#{row['CitePages']} [dupl #{row['SeqNum']}"
                  begin
                    citation.save!
                  rescue ActiveRecord::RecordInvalid
                    logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                    next
                  end
                else # citation error was not already been taken (other validation failure)
                  logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id}, SF.RefID #{sf_ref_id} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                  next
                end
              end
            end

            # kluge that worked but even uglier
            # old_citation = Citation.where(source_id: source_id, citation_object: otu).first # instantiate so nomenclator string can be appended
            # logger.info "Citation (= #{old_citation.id}) to this OTU (= #{otu.id}, SF.TaxonNameID #{sf_taxon_name_id}) from this source (= #{source_id}, SF.RefID #{sf_ref_id}) with these pages (= #{row['CitePages']}) already exists (cite_found_counter = #{cite_found_counter += 1})"
            # old_citation.notes << Note.new(text: "Duplicate citation source to same OTU; nomenclator string = '#{get_nomenclator_string[row['NomenclatorID']]}'", project_id: project_id)
            # # note_text = row['Note'].gsub('|', ':')
            # old_citation.notes << Note.new(text: "Note for duplicate citation = '#{row['Note']}'", project_id: project_id) unless row['Note'].blank?


            ### After citation updated or created

            ## Nomenclator: DataAttribute of citation, NomenclatorID > 0
            if row['NomenclatorID'] != '0' # OR could value: be evaluated below based on NomenclatorID?

              #   
              # TODO: @mbeckman you can no longer create data attributes on Citations, but you can cite data attributes now. This metadata will have to be changed.
              #
              da = DataAttribute.create!(type: 'ImportAttribute',
                                         attribute_subject: citation, # replaces next two lines
                                         # attribute_subject_id: citation.id,
                                         # attribute_subject_type: 'Citation',
                                         import_predicate: 'Nomenclator',
                                         value: get_nomenclator_metadata[row['NomenclatorID']]['nomenclator_string'],
                                         project_id: project_id,
                                         created_at: row['CreatedOn'],
                                         updated_at: row['LastUpdate'],
                                         created_by_id: get_tw_user_id[row['CreatedBy']],
                                         updated_by_id: get_tw_user_id[row['ModifiedBy']]
              )

            end
          end
        end


        def nomenclator_is_original_combination?(protonym, nomenclator_string)
          protonym.cached_original_combination == "<i>#{nomenclator_string}</i>"
        end

        def nomenclator_is_current_name?(protonym, nomenclator_string)
          protonym.cached == nomenclator_string
        end

        def m_original_combination(kn)
          return false, nil if !kn[:is_original_combination]

          id = kn[:protonym].id
          kn[:cr].disambiguate_combination(genus: id, subgenus: id, species: id, subspecies: id, variety: id, form: id)
          kn[:protonym].build_original_combination_from_biodiversity(kn[:cr], kn[:housekeeping_params])
          kn[:protonym].save!
          return true, kn[:protonym]
        end

        def m_single_match(kn) # test for single match
          potential_matches = TaxonName.where(cached: kn[:nomenclator_string], project_id: kn[:project_id])
          if potential_matches.count == 1
            puts 'm_single_match'
            return true, potential_matches.first
          end
          return false, nil
        end

        def m_unambiguous(kn) # test combination is unambiguous and has genus
          if kn[:cr].is_unambiguous?
            if kn[:cr].genus
              puts 'm_unambiguous'
              return true, kn[:cr].combination
            end
          end
          return false, nil
        end

        def m_current_species_homonym(kn) # test known genus and current species homonym
          if kn[:protonym].rank == "species"
            a = kn[:cr].disambiguate_combination(species: kn[:protonym].id)
            if a.get_full_name == kn[:nomenclator_string]
              puts 'm_current_species_homonym'
              return true, a
            end
          end
          return false, nil
        end


        # Returns a symbol/name of the decision to
        # be taken for the row in question
        def decide(knowns)


        end

        # something that can be called in decide
        def decide_method_a

        end




       ######################################################################################################

        # Prior to running next task:
        #   Which dump file to restore
        desc 'time rake tw:project_import:sf_import:citations:create_citations user_id=1 data_directory=/Users/proceps/src/sf/import/onedb2tw/working/'
        #desc 'time rake tw:project_import:sf_import:citations:create_citations user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define create_citations: [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating citations...'

          pwd = rand(36**10).to_s(36)
          @proceps = User.create(email: 'arboridia@gmail.com', password: pwd, password_confirmation: pwd, name: 'proceps', self_created: true, is_flagged_for_password_reset: true)


          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          excluded_taxa = import.get('ExcludedTaxa')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID') # Note this is an OTU associated with a SF.TaxonNameID (probably a bad taxon name)
          get_taxon_name_otu_id = import.get('TWTaxonNameIDToOtuID') # Note this is the OTU offically associated with a real TW.taxon_name_id
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          get_sf_verbatim_ref = import.get('RefIDToVerbatimRef') # key is SF.RefID, value is verbatim string
          get_nomenclator_metadata = import.get('SFNomenclatorIDToSFNomenclatorMetadata')
          get_cvt_id = import.get('CvtProjUriID')
          get_containing_source_id = import.get('TWSourceIDToContainingSourceID') # use to determine if taxon_name_author must be created (orig desc only)
          get_sf_taxon_name_authors = import.get('SFRefIDToTaxonNameAuthors') # contains ordered array of SF.PersonIDs
          get_tw_person_id = import.get('SFPersonIDToTWPersonID')
          # get_sf_file_id = import.get('SFTaxonNameIDToSFFileID')

          otu_not_found_array = []

          tw_taxa_ids = {} #12_Aus_bus -> TaxonName.id

          print "\nMaking list of taxa from the DB, 1st pass\n"
          i = 0
          Protonym.find_each do |t|
            i += 1
            print "\r#{i}"
            if t.rank_class.to_s == 'NomenclaturalRank::Iczn::GenusGroup::Genus' || t.rank_class.to_s == 'NomenclaturalRank::Iczn::GenusGroup::Subgenus'
              tw_taxa_ids[t.project_id.to_s + '_' + t.name] = t.id
            elsif t.rank_class.to_s == 'NomenclaturalRank::Iczn::SpeciesGroup::Species' || t.rank_class.to_s == 'NomenclaturalRank::Iczn::SpeciesGroup::Subspecies'
              tw_taxa_ids[t.project_id.to_s + '_' + t.ancestor_at_rank('genus').name + '_' + t.name] = t.id unless t.ancestor_at_rank('genus').nil?
              tw_taxa_ids[t.project_id.to_s + '_' + t.ancestor_at_rank('subgenus').name + '_' + t.name] = t.id unless t.ancestor_at_rank('subgenus').nil?
            end
          end
          print "\nMaking list of taxa from the DB, 2nd pass\n"
          i = 0
          Protonym.find_each do |t|
            i += 1
            print "\r#{i}"
            if t.rank_class.to_s == 'NomenclaturalRank::Iczn::GenusGroup::Genus' || t.rank_class.to_s == 'NomenclaturalRank::Iczn::GenusGroup::Subgenus'

            elsif t.rank_class.to_s == 'NomenclaturalRank::Iczn::SpeciesGroup::Species' || t.rank_class.to_s == 'NomenclaturalRank::Iczn::SpeciesGroup::Subspecies'
              tw_taxa_ids[t.project_id.to_s + '_' + t.original_genus.name + '_' + t.name] = t.id unless t.original_genus.nil?
              tw_taxa_ids[t.project_id.to_s + '_' + t.original_genus.name] = t.original_genus.id unless t.original_genus.nil?
            end
          end

          path = @args[:data_directory] + 'tblSpeciesNames.txt'
          print "\ntblSpeciesNames.txt\n"
          raise "file #{path} not found" if not File.exists?(path)
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          # SpeciesNameID
          # FileID
          # Name
          # Italicize
          i = 0
          species_name_id = {}
          file.each do |row|
            i += 1
            print "\r#{i}"
            species_name_id[row['SpeciesNameID'].to_i] = [row['Name'].to_s, row['Italicize'].to_i]
          end

          path = @args[:data_directory] + 'tblGenusNames.txt'
          print "\ntblGenusNames.txt\n"
          raise "file #{path} not found" if not File.exists?(path)
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          # GenusNameID
          # FileID
          # Name
          # Italicize
          i = 0
          genus_name_id = {}
          file.each do |row|
            i += 1
            print "\r#{i}"
            genus_name_id[row['GenusNameID'].to_i] = [row['Name'].to_s, row['Italicize'].to_i]
          end

          path = @args[:data_directory] + 'tblNomenclator.txt'
          print "\ntblNomenclator.txt\n"
          raise "file #{path} not found" if not File.exists?(path)
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          # NomenclatorID
          # FileID
          # GenusNameID
          # SubgenusNameID
          # InfragenusNameID
          # SpeciesSeriesNameID
          # SpeciesGroupNameID
          # SpeciesSubgroupNameID
          # SpeciesNameID
          # SubspeciesNameID
          # InfrasubKind
          # InfrasubspeciesNameID
          # SuitableForRanks
          # IdentQualifier - ? or nr.
          # RankQualified
          # LastUpdate
          # ModifiedBy
          # CreatedOn
          # CreatedBy

          i = 0
          nomenclator_ids = {}
          file.each do |row|
            i += 1
            print "\r#{i}"
            a = {}
            a.merge!('genus' => genus_name_id[row['GenusNameID'].to_i]) unless row['GenusNameID'] == '0'
            a.merge!('subgenus' => genus_name_id[row['SubgenusNameID'].to_i]) unless row['SubgenusNameID'] == '0'
            a.merge!('species' => species_name_id[row['SpeciesNameID'].to_i]) unless row['SpeciesNameID'] == '0'
            a.merge!('subspecies' => species_name_id[row['SubspeciesNameID'].to_i]) unless row['SubspeciesNameID'] == '0'
            a.merge!('infrasubspecies' => species_name_id[row['InfrasubspeciesNameID'].to_i]) unless row['InfrasubspeciesNameID'] == '0'
            a.merge!('kind' => row['InfrasubKind']) unless row['InfrasubKind'] == '0'
            a.merge!('qualifier' => row['IdentQualifier']) unless row['IdentQualifier'] == '0'
            nomenclator_ids.merge!(row['NomenclatorID'].to_i => a)
          end

          byebug

#          path = @args[:data_directory] + 'sfNomenclatorTaxonNameIDs.txt'

          # TaxonNameID
          # SeqNum
          # FileID
          # RefID
          # NomenclatorID
          # NomenclatorString
          # GenusTaxonNameID
          # SubgenusTaxonNameID
          # SpeciesSeriesTaxonNameID
          # SpeciesGroupTaxonNameID
          # SpeciesSubgroupTaxonNameID
          # SpeciesTaxonNameID
          # SubspeciesTaxonNameID

#          path = @args[:data_directory] + 'sfNomenclatorStrings.txt'

          # NomenclatorID
          # NomenclatorString
          # IdentQualifier
          # FileID

          count_found = 0
          error_counter = 0
          funny_exceptions_counter = 0
          cite_found_counter = 0
          otu_not_found_counter = 0
          orig_desc_source_id = 0 # make sure only first cite to original description is handled as such (when more than one cite to same source)
          otu_only_counter = 0
          new_combination_counter = 0
          total_combination_counter = 0
          source_used_counter = 0

          unique_bad_nomenclators = {}
          new_name_status = {1 => 0, # unchanged  # key = NewNameStatusID, value = count of instances, initialize keys 1 - 22 = 0 (some keys are missing)
                             2 => 0, # new name
                             3 => 0, # made synonym
                             4 => 0, # made valid or temporary
                             5 => 0, # new combination
                             6 => 0, # new nomen nudum
                             7 => 0, # nomen dubium
                             8 => 0, # missed previous change
                             9 => 0, # still synonym, but of different taxon
                             10 => 0, # gender change
                             17 => 0, # new corrected name
                             18 => 0, # different combination
                             19 => 0, # made valid in new combination
                             20 => 0, # incorrect name before correct
                             22 => 0} # misapplied name

          type_info = {1 => 0, # designate syntypes
                       2 => 0, # designate holotype
                       3 => 0, # designate lectotype
                       4 => 0, # designate neotype
                       5 => 0, # remove syntypes
                       6 => 0, # rulling by comission
                       7 => 0} # unspecified


          base_uri = 'http://speciesfile.org/legacy/'

          cites_id_done = {}
          ['', 'genus', 'subgenus', 'species', 'subspecies', 'infrasubspecies'].each do |rank_pass|

            path = @args[:data_directory] + 'tblCites.txt'
            print "\ntblCites.txt Working on: #{rank_pass}\n"
            raise "file #{path} not found" if not File.exists?(path)
            file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

            # TaxonNameID
            # SeqNum
            # RefID
            # CitePages
            # Note
            # NomenclatorID
            # NewNameStatusID
            # TypeInfoID
            # ConceptChangeID
            # CurrentConcept
            # InfoFlags
            # InfoFlagStatus
            # PolynomialStatus
            # LastUpdate
            # ModifiedBy
            # CreatedOn
            # CreatedBy
            # FileID


            i = 0
            file.each do |row|
              i += 1
              print "\r#{i}"

              #sf_taxon_name_id = row['TaxonNameID']
              next if cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s]

              if excluded_taxa.include? row['TaxonNameID']
                cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = True
                next
              end
              #sf_file_id = row['FileID']
              if skipped_file_ids.include? row['FileID'].to_i
                cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = True
                next
              end

              taxon_name_id = get_tw_taxon_name_id[row['TaxonNameID']] # cannot to_i because if nil, nil.to_i = 0

              if taxon_name_id.nil?
                if get_tw_otu_id[row['TaxonNameID']]
                  logger.info "SF.TaxonNameID = #{row['TaxonNameID']} previously created as OTU (otu_only_counter = #{otu_only_counter += 1})"
                elsif otu_not_found_array.include? row['TaxonNameID'] # already in array (probably seqnum > 1)
                  logger.info "SF.TaxonNameID = #{row['TaxonNameID']} already in otu_not_found_array (total in otu_not_found_counter = #{otu_not_found_counter})"
                else
                  otu_not_found_array << row['TaxonNameID'] # add SF.TaxonNameID to otu_not_found_array
                  logger.info "SF.TaxonNameID = #{row['TaxonNameID']} added to otu_not_found_array (otu_not_found_counter = #{otu_not_found_counter += 1})"
                end
                cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = True
                next
              end

              #sf_ref_id = row['RefID']
              source_id = get_tw_source_id[row['RefID']].to_i
              if source_id == 0
                cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = True
                next
              end

              protonym = TaxonName.find(taxon_name_id)
              project_id = protonym.project_id.to_s #  TaxonName.find(taxon_name_id).project_id.to_s # forced to string for hash value

              nomenclator_string = nil

              # test nomenclator info
              #nomenclator_id = row['NomenclatorID']

              if row['NomenclatorID'] != '0'
                #nomenclator_string = get_nomenclator_metadata[row['NomenclatorID']]['nomenclator_string'].gsub('.  ', '. ') # delete 2nd space after period in var, form, etc.
                #nomenclator_ident_qualifier = get_nomenclator_metadata[row['NomenclatorID']]['ident_qualifier']
                # row['FileID'] = get_nomenclator_metadata[row['NomenclatorID']]['file_id']
                unless nomenclator_ids[row['NomenclatorID'].to_i]['qualifier'].blank?
  #              if nomenclator_ident_qualifier.present? # has some irrelevant text in it
                  # logger.warn "No citation created because IdentQualifier has irrelevant data: (SF.FileID: #{row['FileID']}, SF.TaxonNameID: #{row['TaxonNameID']}, SF.RefID #{row['RefID']} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']})"
                  # create data attr on taxon_name

                  Note.create!(
                      note_object_type: protonym,
                      note_object_id: taxon_name_id,
                      text: "Citation to '#{get_sf_verbatim_ref[row['RefID']]}' not created because accompanying nomenclator ('#{nomenclator_string}') contains irrelevant data ('#{nomenclator_ident_qualifier}')",
                      project_id: project_id,
                      created_at: row['CreatedOn'], # housekeeping data from citation not created
                      updated_at: row['LastUpdate'],
                      created_by_id: get_tw_user_id[row['CreatedBy']],
                      updated_by_id: get_tw_user_id[row['ModifiedBy']]
                  )
                  cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = True
                  next
                end
              end

              if rank_pass == '' && row['NomenclatorID'] != '0'
                next
              elsif rank_pass == 'genus' && (!nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'].nil? || !nomenclator_ids[row['NomenclatorID'].to_i]['species'].nil? || !nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'].nil? || !nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'].nil?)
                next
              elsif rank_pass == 'subgenus' && (!nomenclator_ids[row['NomenclatorID'].to_i]['species'].nil? || !nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'].nil? || !nomenclator_ids[nrow['NomenclatorID'].to_i]['infrasubspecies'].nil?)
                next
              elsif rank_pass == 'species' && (!nomenclator_ids[nomenclator_id.to_i]['subspecies'].nil? || !nomenclator_ids[nomenclator_id.to_i]['infrasubspecies'].nil?)
                next
              elsif rank_pass == 'subspecies' && (!nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'].nil?)
                next
              end

              #logger.info "Working with TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id}, SF.RefID #{row['RefID']} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']} (count #{count_found += 1}) \n"

              #cite_pages = row['CitePages']

              new_name_uri = (base_uri + 'new_name_status/' + row['NewNameStatusID']) unless row['NewNameStatusID'] == '0'
              type_info_uri = (base_uri + 'type_info/' + row['TypeInfoID']) unless row['TypeInfoID'] == '0'
              info_flag_status_uri = (base_uri + 'info_flag_status/' + row['InfoFlagStatus']) unless row['InfoFlagStatus'] == '0'

              new_name_cvt_id = get_cvt_id[project_id][new_name_uri]
              type_info_cvt_id = get_cvt_id[project_id][type_info_uri]
              info_flag_status_cvt_id = get_cvt_id[project_id][info_flag_status_uri]

              # ap "NewNameStatusID = #{new_name_cvt_id.to_s}; TypeInfoID = #{type_info_cvt_id.to_s}" # if new_name_cvt_id

              metadata = {
                  ## Note: Add as attribute before save citation
                  notes_attributes: [{text: row['Note'], # (row['Note'].blank? ? nil :   rejected automatically by notable
                                      project_id: project_id,
                                      created_at: row['CreatedOn'],
                                      updated_at: row['LastUpdate'],
                                      created_by_id: get_tw_user_id[row['CreatedBy']],
                                      updated_by_id: get_tw_user_id[row['ModifiedBy']]}],


                  tags_attributes: [{keyword_id: new_name_cvt_id, project_id: project_id}, {keyword_id: type_info_cvt_id, project_id: project_id}],

                  ## InfoFlagStatus: Add confidence, 1 = partial data or needs review, 2 = complete data
                  confidences_attributes: [{confidence_level_id: info_flag_status_cvt_id, project_id: project_id}]
              }

              is_original = false

              # Original description citation most likely already exists but pages are source pages, not cite pages
              citation = Citation.where(source_id: source_id, citation_object_type: 'TaxonName', citation_object_id: taxon_name_id, is_original: true).first


#              new_name_status = {1 => 0, # unchanged  # key = NewNameStatusID, value = count of instances, initialize keys 1 - 22 = 0 (some keys are missing)
#                                 2 => 0, # new name
#                                 3 => 0, # made synonym
#                                 4 => 0, # made valid or temporary
#                                 5 => 0, # new combination
#                                 6 => 0, # new nomen nudum
#                                 7 => 0, # nomen dubium
#                                 8 => 0, # missed previous change
#                                 9 => 0, # still synonym, but of different taxon
#                                 10 => 0, # gender change
#                                 17 => 0, # new corrected name
#                                 18 => 0, # different combination
#                                 19 => 0, # made valid in new combination
#                                 20 => 0, # incorrect name before correct
#                                 22 => 0} # misapplied name



              string = [nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0], nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0], nomenclator_ids[row['NomenclatorID'].to_i]['species'][0], nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'][0], nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'][0]]..compact.join('_')

              if citation.nil?
                next
              elsif !citation.nil? && orig_desc_source_id != source_id
                orig_desc_source_id = source_id # prevents duplicate citation to same source being processed as original description
                citation.notes << Note.new(text: row['Note'], project_id: project_id) unless row['Note'].blank?
                citation.update(metadata.merge(pages: row['CitePages']))

                is_original = true
                # logger.info "Citation found: citation.id = #{citation.id}, taxon_name_id = #{taxon_name_id}, cite_pages = '#{row['CitePages']}' (cite_found_counter = #{cite_found_counter += 1})"

                if get_containing_source_id[source_id.to_s] # create taxon_name_author role for contained Refs only
                  get_sf_taxon_name_authors[row['RefID']].each do |sf_person_id| # person_id from author_array
                    role = Role.create!(
                        person_id: get_tw_person_id[sf_person_id],
                        type: 'TaxonNameAuthor',
                        role_object_id: taxon_name_id,
                        role_object_type: 'TaxonName',
                        project_id: project_id, # role is project_role
                        )
                  end
                end


                if rank_pass == 'genus'
                  byebug if protonym.name != nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]
                  protonym.original_genus = protonym
                  protonym.save
                elsif rank_pass == 'subgenus'
                  byebug if protonym.name != nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]
                  protonym.original_subgenus = protonym
                  protonym.original_genus = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]) if protonym.original_genus.nil? && nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus']
                elsif rank_pass == 'species'
                  byebug if protonym.name != nomenclator_ids[row['NomenclatorID'].to_i]['species'][0]
                  protonym.original_species = protonym
                  protonym.original_subgenus = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]]) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['subgenus']
                  protonym.original_genus = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]) if protonym.original_genus.nil? && nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus']
                elsif rank_pass == 'subspecies'
                  byebug if protonym.name != nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'][0]
                  protonym.original_subspecies = protonym
                  protonym.original_species = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['species'][0]]) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && nomenclator_ids[row['NomenclatorID'].to_i]['species']
                  protonym.original_subgenus = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]]) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['subgenus']
                  protonym.original_genus = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]) if protonym.original_genus.nil? && nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus']
                elsif rank_pass == 'infrasubspecies'
                  byebug if protonym.name != nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'][0]
                  if nomenclator_ids[row['NomenclatorID'].to_i]['kind'] == '0'
                    protonym.original_form = protonym
                  elsif nomenclator_ids[row['NomenclatorID'].to_i]['kind'] == '1'
                      protonym.original_variety = protonym
                  elsif ['2', '3'].include?(nomenclator_ids[row['NomenclatorID'].to_i]['kind'])
                    protonym.original_variety = protonym
                    protonym.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::Excluded::Infrasubspecific')
                  end
                  protonym.original_subspecies = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'][0]]) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && nomenclator_ids[row['NomenclatorID'].to_i]['subspecies']
                  protonym.original_species = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['species'][0]]) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && nomenclator_ids[row['NomenclatorID'].to_i]['species']
                  protonym.original_subgenus = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]]) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['subgenus']
                  protonym.original_genus = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]) if protonym.original_genus.nil? && nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus']
                end
                protonym.save!
                string = [project_id, protonym.original_genus.name, protonym.original_subgenus.name, protonym.original_species.name, protonym.original_subspecies.name, protonym.original_variety.name, protonym.original_form.name].compact.join('_')
                tw_taxa_ids[string] = protonym.id
                cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = True
                next
              elsif tw_taxa_ids[string]
                # just create another citation
              else
                p = Protonym.new
                if rank_pass == 'genus'
                  p.rank_class = Ranks.lookup(:iczn, 'Genus')
                  p.name = nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]
                  p.original_genus = p
                elsif rank_pass == 'subgenus'
                  p.rank_class = Ranks.lookup(:iczn, 'Genus')
                  p.name = nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]
                  p.original_subgenus = p
                  p.original_genus = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]) if protonym.original_genus.nil? && nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus']
                elsif rank_pass == 'species'
                  p.rank_class = Ranks.lookup(:iczn, 'Species')
                  p.name = nomenclator_ids[row['NomenclatorID'].to_i]['species'][0]
                  p.original_species = p
                  p.original_subgenus = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]]) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['subgenus']
                  p.original_genus = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]) if protonym.original_genus.nil? && nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus']
                elsif rank_pass == 'subspecies'
                  p.rank_class = Ranks.lookup(:iczn, 'Species')
                  p.name = nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'][0]
                  p.original_subspecies = p
                  p.original_species = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['species'][0]]) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && nomenclator_ids[row['NomenclatorID'].to_i]['species']
                  p.original_subgenus = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]]) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['subgenus']
                  p.original_genus = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]) if protonym.original_genus.nil? && nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus']
                elsif rank_pass == 'infrasubspecies'
                  p.rank_class = Ranks.lookup(:iczn, 'Species')
                  p.name = nomenclator_ids[row['NomenclatorID'].to_i]['infrasubspecies'][0]
                  if nomenclator_ids[row['NomenclatorID'].to_i]['kind'] == '0'
                    p.original_form = p
                  elsif nomenclator_ids[row['NomenclatorID'].to_i]['kind'] == '1'
                    p.original_variety = p
                  elsif ['2', '3'].include?(nomenclator_ids[row['NomenclatorID'].to_i]['kind'])
                    p.original_variety = p
                    p.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::Excluded::Infrasubspecific')
                  end
                  p.original_subspecies = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subspecies'][0]]) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && nomenclator_ids[row['NomenclatorID'].to_i]['subspecies']
                  p.original_species = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0] + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['species'][0]]) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus'] && nomenclator_ids[row['NomenclatorID'].to_i]['species']
                  p.original_subgenus = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['subgenus'][0]]) if nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['subgenus']
                  p.original_genus = TaxonName.find(tw_taxa_ids[project_id + '_' + nomenclator_ids[row['NomenclatorID'].to_i]['genus'][0]]) if protonym.original_genus.nil? && nomenclator_ids[row['NomenclatorID'].to_i] && nomenclator_ids[row['NomenclatorID'].to_i]['genus']
                end
                p.project_id = project_id
                p.created_at = row['CreatedOn']
                p.updated_at = row['LastUpdate']
                p.created_by_id = get_tw_user_id[row['CreatedBy']]
                p.updated_by_id = get_tw_user_id[row['ModifiedBy']]
                p.taxon_name_relationships.new(object_taxon_name: protonym, type: 'TaxonNameRelationship::Iczn::Invalidating')
                p.save!
                tw_taxa_ids[string] = p.id
                cites_id_done[row['TaxonNameID'].to_s + '_' + row['SeqNum'].to_s] = True
                protonym = p
              end



              if !nomenclator_string.blank? && !nomenclator_string.include?('?') # has ? in string, skip combo but record string as tag
                if !nomenclator_is_original_combination?(protonym, nomenclator_string) && !nomenclator_is_current_name?(protonym, nomenclator_string)
                  combination = nil

                  # @todo commented out 9 July
                  # # [INFO]2018-03-21 04:23:59.785: total funny exceptions = '13410', total unique_bad_nomenclators = '4933'
                  # # [INFO]2018-03-30 03:43:54.967: total funny exceptions = '56295', total unique_bad_nomenclators = '23051', new combo total = 14097
                  # # [INFO]2018-03-31 18:44:23.471: total funny exceptions = '35106', total unique_bad_nomenclators = '15822', new combo total = 21,275
                  # cr = TaxonWorks::Vendor::Biodiversity::Result.new(query_string: nomenclator_string, project_id: project_id, code: :iczn)
                  #
                  # kn = {
                  #     project_id: project_id,
                  #     nomenclator_string: nomenclator_string,
                  #     cr: cr,
                  #     protonym: protonym,
                  #
                  #     housekeeping: {
                  #         project_id: project_id,
                  #         created_at: row['CreatedOn'],
                  #         updated_at: row['LastUpdate'],
                  #         created_by_id: get_tw_user_id[row['CreatedBy']],
                  #         updated_by_id: get_tw_user_id[row['ModifiedBy']]
                  #     }
                  # }
                  #
                  # kn[:is_original_combination] = true if is_original
                  #
                  # done = false
                  #
                  # [:m_single_match, :m_unambiguous, :m_current_species_homonym].each do |m|
                  #   passed, c = send(m, kn) # return passed & c (= combination); args to m (= method), kn (= knowns)
                  #   if passed
                  #     if c.new_record?
                  #       c.by = 1
                  #       c.project_id = project_id
                  #       c.save!
                  #       new_combination_counter += 1
                  #     end
                  #     done = true
                  #     taxon_name_id = c.id
                  #     # total_combination_counter += 1
                  #   end
                  #   break if done
                  # end
                  #
                  # if done
                  #   logger.info Rainbow("Successful combination: new_combination_counter = #{new_combination_counter}, total_combination_counter = #{total_combination_counter}").rebeccapurple.bold
                  # else # unsuccessful
                  #   funny_exceptions_counter += 1
                  #   unique_bad_nomenclators[nomenclator_string] = project_id
                  #
                  #   logger.warn "Funny exceptions ELSE nomenclator_string = '#{nomenclator_string}', cr.detail = '#{cr.detail}', cr.ambiguous_ranks = '#{cr.ambiguous_ranks}' (unique_bad_nomenclators.count = #{unique_bad_nomenclators.count})"
                  # end
                end
              end

              if !is_original
                citation = Citation.new(
                    metadata.merge(
                        source_id: source_id,
                        pages: cite_pages,
                        is_original: (row['SeqNum'] == '1' ? true : false),
                        citation_object_type: 'TaxonName',
                        citation_object_id: taxon_name_id,
                        project_id: project_id,
                        created_at: row['CreatedOn'],
                        updated_at: row['LastUpdate'],
                        created_by_id: get_tw_user_id[row['CreatedBy']],
                        updated_by_id: get_tw_user_id[row['ModifiedBy']]
                    )
                )

                begin
                  citation.save!
                rescue ActiveRecord::RecordInvalid # citation not valid

                  # yes I know this is ugly but it works
                  if citation.errors.messages[:source_id].nil?
                    logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id},
  SF.RefID #{row['RefID']} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                    next
                  else # make pages unique and save again
                    if citation.errors.messages[:source_id].include?('has already been taken') # citation.errors.messages[:source_id][0] == 'has already been taken'
                      citation.pages = "#{cite_pages} [dupl #{row['SeqNum']}"
                      begin
                        citation.save!
                      rescue ActiveRecord::RecordInvalid
                        # [ERROR]2018-03-30 17:09:43.127: Citation ERROR [TW.project_id: 11, SF.TaxonNameID 1152999 = TW.taxon_name_id 47338, SF.RefID 16047 = TW.source_id 12047, SF.SeqNum 2, nomenclator_string = Limnoperla jaffueli, name_status = 3] (total_error_counter = 1, source_used_counter = 1): Source has already been taken
                        logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id}, SF.RefID #{row['RefID']} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}, nomenclator_string = #{nomenclator_string}, name_status = #{row['NewNameStatusID']}], (current_error_counter = #{error_counter += 1}, source_used_counter = #{source_used_counter += 1}): " + citation.errors.full_messages.join(';')
                        logger.info "NewNameStatusID = #{row['NewNameStatusID']}, count = #{new_name_status[row['NewNameStatusID'].to_i] += 1}"
                        next
                      end
                    else # citation error was not already been taken (other validation failure)
                      logger.error "Citation ERROR [TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id}, SF.RefID #{row['RefID']} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']}] (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
                      next
                    end
                  end
                end
              end

              ### After citation updated or created
              ## Nomenclator: DataAttribute of citation, NomenclatorID > 0

              if nomenclator_string # OR could value: be evaluated below based on NomenclatorID?
                da = DataAttribute.new(type: 'ImportAttribute',
                                       # attribute_subject_id: citation.id,
                                       # attribute_subject_type: 'Citation',
                                       attribute_subject: citation, # replaces two lines above
                                       import_predicate: 'Nomenclator',
                                       value: "#{nomenclator_string} (TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id}, SF.RefID #{row['RefID']} = TW.source_id #{source_id}, SF.SeqNum #{row['SeqNum']})",
                                       project_id: project_id,
                                       created_at: row['CreatedOn'],
                                       updated_at: row['LastUpdate'],
                                       created_by_id: get_tw_user_id[row['CreatedBy']],
                                       updated_by_id: get_tw_user_id[row['ModifiedBy']]
                )
                begin
                  da.save!
                    # puts 'DataAttribute Nomenclator created'
                rescue ActiveRecord::RecordInvalid # da not valid
                  logger.error "DataAttribute Nomenclator ERROR NomenclatorID = #{row['NomenclatorID']}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id} (error_counter = #{error_counter += 1}): " + da.errors.full_messages.join(';')
                end
              end

              ## ConceptChange: For now, do not import, only 2000 out of 31K were not automatically calculated, downstream in TW we will use Euler
              ## CurrentConcept: bit: For now, do not import
              # select * from tblCites c inner join tblTaxa t on c.TaxonNameID = t.TaxonNameID where c.CurrentConcept = 1 and t.NameStatus = 7
              ## InfoFlags: Attribute/topic of citation?!! Treat like StatusFlags for individual values
              # Use as topics on citations for OTUs, make duplicate citation on OTU, then topic on that citation

              info_flags = row['InfoFlags'].to_i
              if info_flags == 0
                next
              end

              # !! from here on we're back to referencing OTUs that were created PRE combination world
              otu_id = get_taxon_name_otu_id[protonym.id.to_s].to_i

              if otu_id == 0
                logger.warn "OTU error, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id} (OTU not found: #{otu_not_found_counter += 1})"
                next
              end

              base_cite_info_flags_uri = (base_uri + 'cite_info_flags/') # + bit_position below
              cite_info_flags_array = Utilities::Numbers.get_bits(info_flags)

              citation_topics_attributes = cite_info_flags_array.collect {|bit_position|
                {topic_id: get_cvt_id[project_id][base_cite_info_flags_uri + bit_position.to_s],
                 project_id: project_id,
                 created_at: row['CreatedOn'],
                 updated_at: row['LastUpdate'],
                 created_by_id: get_tw_user_id[row['CreatedBy']],
                 updated_by_id: get_tw_user_id[row['ModifiedBy']]
                }
              }

              otu_citation = Citation.new(
                  source_id: source_id,
                  pages: cite_pages,
                  is_original: (row['SeqNum'] == '1' ? true : false),
                  citation_object_type: 'Otu',
                  citation_object_id: otu_id,
                  citation_topics_attributes: citation_topics_attributes,
                  project_id: project_id,
                  created_at: row['CreatedOn'],
                  updated_at: row['LastUpdate'],
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']]
              )

              begin
                otu_citation.save!
                puts 'OTU citation created'
              rescue ActiveRecord::RecordInvalid
                logger.error "OTU citation ERROR SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{protonym.id} = otu_id #{otu_id} (error_counter = #{error_counter += 1}): " + otu_citation.errors.full_messages.join(';')
              end

              ## PolynomialStatus: based on NewNameStatus: Used to detect "fake" (previous combos) synonyms
              # Not included in initial import; after import, in TW, when we calculate CoL output derived from OTUs, and if CoL output is clearly wrong then revisit this issue
            end
          end # genus, subgenus, species, subspecies







          # logger.info "total funny exceptions = '#{funny_exceptions_counter}', total unique_bad_nomenclators = '#{unique_bad_nomenclators.count}', \n unique_bad_nomenclators = '#{unique_bad_nomenclators}'"
          # ap "total funny exceptions = '#{funny_exceptions_counter}', total unique_bad_nomenclators = '#{unique_bad_nomenclators.count}', \n unique_bad_nomenclators = '#{unique_bad_nomenclators}'"
          puts 'new_name_status hash:'
          ap new_name_status
        end

      end
    end
  end
end


