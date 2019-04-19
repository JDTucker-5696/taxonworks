FactoryBot.define do

  factory :taxon_name_relationship, traits: [:housekeeping] do

    initialize_with { new(type: type) } 

    factory :valid_taxon_name_relationship do
      association :subject_taxon_name, factory: :relationship_genus
      association :object_taxon_name, factory: :relationship_family
      type { 'TaxonNameRelationship::Typification::Family' }
    end

    factory :type_genus_relationship do
      association :subject_taxon_name, factory: :relationship_genus
      association :object_taxon_name, factory: :relationship_family
      type { 'TaxonNameRelationship::Typification::Family' }
    end

    factory :type_species_relationship do
      association :subject_taxon_name, factory: :relationship_species
      association :object_taxon_name, factory: :relationship_genus
      type { 'TaxonNameRelationship::Typification::Genus::Monotypy::OriginalMonotypy' }
    end
  end
end
