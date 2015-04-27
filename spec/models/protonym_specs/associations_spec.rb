require 'rails_helper'

describe Protonym, type: :model, group: [:nomenclature, :protonym] do

  before(:all) do
    TaxonName.delete_all
    TaxonNameRelationship.delete_all
    @order = FactoryGirl.create(:iczn_order)
  end

  after(:all) do
    TaxonNameRelationship.delete_all
    TaxonName.delete_all
    Source.delete_all
  end

  let(:protonym) { Protonym.new }
  let(:root) { Protonym.where(name: 'Root').first  }

  context 'associations' do
    before(:all) do
      @family = FactoryGirl.create(:relationship_family, name: 'Aidae', parent: @order)
      @genus = FactoryGirl.create(:relationship_genus, name: 'Aus', parent: @family)
      @protonym = FactoryGirl.create(:relationship_species, name: 'aus', parent: @genus)
      @species_type_of_genus = FactoryGirl.create(:taxon_name_relationship,
                                                  subject_taxon_name: @protonym,
                                                  object_taxon_name: @genus,
                                                  type: 'TaxonNameRelationship::Typification::Genus::Monotypy::Original')
      @genus_type_of_family = FactoryGirl.create(:taxon_name_relationship,
                                                 subject_taxon_name: @genus,
                                                 object_taxon_name: @family,
                                                 type: 'TaxonNameRelationship::Typification::Family')
    end

    context 'has_many' do
      specify 'original_combination_relationships' do 
        expect(protonym).to respond_to(:original_combination_relationships)
      end

      specify 'combination_relationships' do 
        expect(protonym).to respond_to(:combination_relationships)
      end

      specify 'combinations' do 
        expect(protonym).to respond_to(:combinations)
      end
    end

    context 'has_one' do
      specify 'original_combination_source' do
        expect(protonym).to respond_to(:original_combination_source)
      end

      specify 'originally classified' do
        expect(protonym.source_classified_as = Protonym.new).to be_truthy
      end

      specify 'gender' do
        gender = FactoryGirl.create(:taxon_name_classification, taxon_name: @genus, type: 'TaxonNameClassification::Latinized::Gender::Masculine')
        expect(gender.valid?).to be_truthy
        expect(gender.errors.include?(:taxon_name_id)).to be_falsey
        @genus.reload
        expect(@genus.gender_name).to eq('masculine')
        gender2 = FactoryGirl.build_stubbed(:taxon_name_classification, taxon_name: @genus, type: 'TaxonNameClassification::Latinized::Gender::Feminine')
        gender2.valid?
        expect(gender2.errors.include?(:taxon_name_id)).to be_truthy
      end
    end

    context 'added via TaxonNameRelationships' do
      TaxonNameRelationship.descendants.each do |d|
        if d.respond_to?(:assignment_method) && (not d.name.to_s =~ /TaxonNameRelationship::Combination|SourceClassifiedAs/)
          if d.name.to_s =~ /TaxonNameRelationship::(Iczn|Icn)/
            relationship = "#{d.assignment_method}_relationship".to_sym
            relationships = "#{d.inverse_assignment_method}_relationships".to_sym
            method = d.assignment_method.to_sym
            methods = d.inverse_assignment_method.to_s.pluralize.to_sym
          elsif d.name.to_s =~ /TaxonNameRelationship::(OriginalCombination|Typification)/ # 
            relationship = "#{d.inverse_assignment_method}_relationship".to_sym
            relationships = "#{d.assignment_method}_relationships".to_sym
            method = d.inverse_assignment_method.to_sym
            methods = d.assignment_method.to_s.pluralize.to_sym
          end

          specify relationship do
            expect(protonym).to respond_to(relationship)
          end
          specify relationships do
            expect(protonym).to respond_to(relationships)
          end
          specify method do
            expect(protonym.send("#{method}=", Protonym.new)).to be_truthy 
          end

          specify methods do
            expect(protonym).to respond_to(methods)
          end
        end
      end
    end

    context 'example usage' do
      context 'typification' do
        specify 'type_taxon_name' do
          expect(@genus).to respond_to(:type_taxon_name)
          expect(@genus.type_taxon_name).to eq(@protonym)
          expect(@family.type_taxon_name).to eq(@genus)
        end 

        specify 'type_taxon_name_relationship' do
          expect(protonym).to respond_to(:type_taxon_name_relationship)
          expect(@genus.type_taxon_name_relationship.id).to eq(@species_type_of_genus.id)
          expect(@family.type_taxon_name_relationship.id).to eq(@genus_type_of_family.id)
        end 

        specify 'has at most one has_type relationship' do
          extra_type_relation = FactoryGirl.build_stubbed(:taxon_name_relationship,
                                                          subject_taxon_name: @genus,
                                                          object_taxon_name: @family,
                                                          type: 'TaxonNameRelationship::Typification::Family')
          # Handled by TaxonNameRelationship validates_uniqueness_of :subject_taxon_name_id,  scope: [:type, :object_taxon_name_id]
          expect(extra_type_relation.valid?).to be_falsey
        end
      end

      context 'latinized' do
        specify 'has at most one latinization' do
          c1 = FactoryGirl.create(:taxon_name_classification, taxon_name: @genus, type: 'TaxonNameClassification::Latinized::Gender::Feminine')
          c2 = FactoryGirl.build_stubbed(:taxon_name_classification, taxon_name: @genus, type: 'TaxonNameClassification::Latinized::PartOfSpeech::Ajective')
          expect(c2.valid?).to be_falsey
        end
      end 

      specify 'type_of_relationships' do
        expect(@protonym.type_of_relationships.collect{|i| i.id}).to eq([@species_type_of_genus.id])
      end

      specify 'type_of_taxon_names' do
        expect(@protonym.type_of_taxon_names).to eq([@genus])
      end

      specify 'type species' do
        expect(@genus.type_species).to eq(@protonym)
      end

      specify 'type species relationship' do
        expect(@genus.type_species_relationship.id).to eq(@species_type_of_genus.id)
      end

      specify 'type of genus' do
        expect(@protonym.type_of_genus.first).to eq(@genus)
      end

      specify 'type of genus relationship' do
        expect(@protonym.type_of_genus_relationships.first.id).to eq(@species_type_of_genus.id)
      end
    end
  end # end associations
end
