namespace :tw do
  namespace :project_import do
    namespace :sf_import do

      # @todo: Matt: combinations for citations

      # rake tw:db:restore backup_directory=../db_backup file=../db_backup/0_pristine_tw_init_all/2016-04-26_192513UTC.dump

      desc 'time rake tw:project_import:sf_import:run_all_import_tasks user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
      #  time rake tw:project_import:sf_import:run_all_import_tasks user_id=1 data_directory=/Users/sfg/src/onedb2tw/working/
      task run_all_import_tasks: [

          # 'tw:db:restore backup_directory=../db_backup file=../db_backup/0_pristine_tw_init_all/2016-04-26_192513UTC.dump',
          # rake tw:db:restore_last backup_directory=../db_backup/0_pristine_tw_init_all/

          # 'start:list_skipped_file_ids',
          # 'start:create_users',
          # 'start:create_people',
          # 'start:map_serials',
          # # '1_after_serials': 14m32.537s on 30 Oct 2018
          # #
          # 'start:map_ref_links',
          # 'start:list_verbatim_refs',
          # # '2_after_verbatim_refs': 0m24.701s on 30 Oct 2018
          # #
          # 'start:create_projects',
          # 'start:create_sf_book_hash',
          # 'start:map_pub_type',
          # # '3_after_pub_type': 0m27.396s on 30 Oct 2018
          # # 1, 2, 3: 18m34.415s on 15 July 2019
          #
          # 'start:create_sources',
          # '4_after_create_sources': 41m36.692s on 31 Oct 2018
          #
          # 'start:create_misc_ref_info',
          # 'start:create_source_roles',
          # # '5_after_source_roles': 76m51.040s on 7 Nov 2018; 132m58.252s b1_ on 25 Nov 2018; 65m3.663s on 30 May 2019; 70m34.672s on 16 July 2019
          # # 4, 5: 104m51.735s on 15 July 2019
          # #
          # 'taxa:list_excluded_taxa',
          # 'taxa:create_sf_taxa_misc_info',
          # 'taxa:create_rank_hash',
          # 'taxa:create_animalia_below_root',
          # 'taxa:create_sf_synonym_id_to_new_parent_id_hash',
          # 'taxa:create_otus_for_ill_formed_names_hash',
          # # '6_after_otus_hash': 0m55.165s on 8 Nov 2018; 3m20.635s on 30 May 2019; 3m21.575s on 16 July 2019
          # #
          'taxa:create_all_sf_taxa_pass1',
          # # '7_after_run_all_taxa': 298m12.627s on 8 Nov 2018; 347m33.882s on 13 June 2018
          # #
          # 'taxa:create_type_species',
          # # '8_after_type_species': 6m33.833s on 13 Nov 2018; no log summary appears at end
          # #
          # 'taxa:create_type_genera',
          # # '9_after_type_genera': 1m8.873ss on 13 Nov 2018
          # #
          # 'taxa:create_some_related_taxa',
          # # '10_after_some_related_taxa': 3m2.116s on 13 Nov 2018
          # #
          # 'taxa:create_status_flag_relationships',
          # # '11_after_status_flag_rels': dumps 7-11 took 466m18.113s on 7 Feb 2019; 171m8.794s on 14 Nov 2018; 8-11 took 186m52.699s on 31 May 2019
          # #
          # 'pre_cites:import_nomenclator_strings',
          # 'pre_cites:create_cvts_for_citations',
          # 'pre_cites:create_sf_family_taxon_name_authors',
          # 'pre_cites:check_original_genus_ids',
          # # '12_after_orig_genus_ids': 21m32.190s on 8 Feb 2019; 19m59.741s on 14 Nov 2018
          # #
          # 'specimens:create_specimen_unique_id',
          # 'specimens:create_sf_geo_level4_hash',
          # # '13_after_geo_level_4': 2m9.065s on 14 Nov 2018; 12-13 took 23m20.826s on 31 May 2019
          # #
          # 'specimens:geographic_area_ids',
          # 'specimens:collecting_events',
          # # 14_after_coll_events': 235m50.824s for dumps 13 & 14 on 8 Feb 2019; 38m14.238s on 15 Nov 2018; 42m43.927s on 16 June 2018; 47m53.101s on 26 June 2018; 207m46.345s on 31 May 2019
          # #
          # 'specimens:import_sf_depos',
          # 'specimens:create_biocuration_classes',
          # 'specimens:create_specimen_category_counts',
          # 'specimens:create_sf_source_metadata',
          # 'specimens:create_sf_identification_metadata',
          # # '15_after_identification_metadata': 9m47.689s on 15 Nov 2018
          # #
          # 'specimens:get_ident_qualifier_from_nomenclator',
          # 'specimens:create_sf_loc_col_events_metadata',
          # # '16_after_col_events_metadata': 10m17.584s on 15 Nov 2018; 15-16 took 21m27.003s
          #
          # 654m43.830s before crash on 13 Jan 2019
          # 'specimens:collection_objects',
          # # '17_after_collection_objects': 197m20.585s on 19 Mar 2019; 211m4.168s on 1 Feb 2019; 202m27.938s on 20 Nov 2018; 227m33.097s on 15 Nov 2018; 187m21.639s on 1 June 2019
          # #
          # 'supplementary:taxon_info',
          # # 0m58.912s on 21 Nov 2018
          # 'supplementary:scrutiny_related',
          # # '18_after_scrutinies': 12m12.489s on 21 Nov 2018 [from 11:23:10.299 to 11:29:51.063, scrutiny authors being processed, no screen activity]
          # #
          # 'media:create_language_hash',
          # 'media:create_common_names',
          # 'media:create_otu_website_links',
          # # 19_after_links: 18-19 took 19m3.097s on 2 June 2019
          # #
          # 'citations:create_citations',
          # # 20_after_taxon_citations: close to 10h (592m44.659s on 10 July 2015, 591m42.625s on 6 Sept 2018); 2023m53.988s (33.716666 hours) on 4 June 2019
          #
          # 'citations:create_combinations',
          # # 21_after_create_combinations: 112m27.918s on 6 June 2019
          # #
          # 'citations:create_otu_cites',
          # # 25_after_otu_cites: 1m2.000s on 16 July 2018; 0m55.486s on 7 Sept 2018; 2m1.501s on 2 July 2019
          #
          #
          # 'last:filter_users'
          # # '99_after_filter_users': 5m26.662s on 25 Feb 2019

      ] do
        puts 'Ran all tasks!'

      end
    end
  end
end

