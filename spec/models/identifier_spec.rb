require 'rails_helper'

describe Identifier, :type => :model do
  let(:identifier) { FactoryGirl.build(:identifier) }
  let(:namespace) {FactoryGirl.create(:valid_namespace)}
  let(:specimen1) {FactoryGirl.create(:valid_specimen)}
  let(:specimen2) {FactoryGirl.create(:valid_specimen)}

  context 'validation' do

    context 'requires' do
      before do
        identifier.valid?
      end

      # !! This test fails not because of a validation, but because of a NOT NULL constraint. 
      specify 'identifier_object' do 
        # this eliminate all model based validation requirements
        identifier.type = 'Identifier::Local::CatalogNumber'
        identifier.namespace_id = FactoryGirl.create(:valid_namespace).id
        identifier.identifier = '123'

        expect{identifier.save}.to raise_error ActiveRecord::StatementInvalid
      end

      specify 'identifier' do
        expect(identifier.errors.include?(:identifier)).to be_truthy
      end

      specify 'type' do
        expect(identifier.errors.include?(:type)).to be_truthy
      end
    end

    # sanity check for Housekeeping, which is tested elsewhere 
    context 'sets housekeeping' do
      before {identifier.valid?}
      specify 'creator' do
        expect(identifier.errors.include?(:creator)).to be_falsey
      end

      specify 'updater' do
        expect(identifier.errors.include?(:updater)).to be_falsey
      end

      specify 'with <<' do
        expect(specimen1.identifiers.count).to eq(0)
        specimen1.identifiers << Identifier::Local::CatalogNumber.new(namespace: namespace, identifier: 456)
        expect(specimen1.save).to be_truthy 
        expect(specimen1.identifiers.first.creator.nil?).to be_falsey
        expect(specimen1.identifiers.first.updater.nil?).to be_falsey
        expect(specimen1.identifiers.first.project.nil?).to be_falsey
      end

      specify 'with .build' do
        expect(specimen1.identifiers.count).to eq(0)
        specimen1.identifiers.build(type: 'Identifier::Local::CatalogNumber', namespace: namespace, identifier: 456)
        expect(specimen1.save).to be_truthy 
        expect(specimen1.identifiers.first.creator.nil?).to be_falsey
        expect(specimen1.identifiers.first.updater.nil?).to be_falsey
        expect(specimen1.identifiers.first.project.nil?).to be_falsey
      end

      specify 'with new objects and <<' do
        s = FactoryGirl.build(:valid_specimen)
        s.identifiers <<  Identifier::Local::CatalogNumber.new(namespace: namespace, identifier: 456)
        expect(s.save).to be_truthy
        expect(s.identifiers.count).to eq(1)
        expect(s.identifiers.first.creator.nil?).to be_falsey
        expect(s.identifiers.first.updater.nil?).to be_falsey
        expect(s.identifiers.first.project.nil?).to be_falsey
      end

      specify 'with new objects and build' do
        s = FactoryGirl.build(:valid_specimen)
        s.identifiers.build(type: 'Identifier::Local::CatalogNumber', namespace: namespace, identifier: 456)
        expect(s.save).to be_truthy
        expect(s.identifiers.count).to eq(1)
        expect(s.identifiers.first.creator.nil?).to be_falsey
        expect(s.identifiers.first.updater.nil?).to be_falsey
        expect(s.identifiers.first.project.nil?).to be_falsey
      end
    end 

    specify 'has an identifier_object' do
      expect(identifier).to respond_to(:identifier_object)
      expect(identifier.identifier_object).to be(nil)   
    end

    specify 'you can\'t add non-unique identifiers of the same type to a two objects' do
      i1 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen1, identifier: 123)
      i2 = Identifier::Local::CatalogNumber.new(namespace: namespace, identifier_object: specimen2, identifier: 123)
      expect(i1.save).to be_truthy
      expect(i2.save).to be_falsey
      expect(i2.errors.include?(:identifier)).to be_truthy
    end
  end

  context 'scopes' do
    specify '#of_type(some_type_short_name) returns identifiers of that type' do
      i2 = Identifier::Global::Uri.create(identifier_object: specimen1, identifier: 'http:://foo.com/123')
      i1 = Identifier::Local::CatalogNumber.create(identifier_object: specimen1, namespace: namespace, identifier: 123)

      expect(specimen1.identifiers.of_type(:uri).to_a).to eq([i2])
      expect(specimen1.identifiers.of_type(:catalog_number).to_a).to eq([i1])
    end
  end

end
