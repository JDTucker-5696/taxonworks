require 'rails_helper'

describe BiologicalAssociation, type: :model do

  let(:biological_association) { FactoryBot.build(:biological_association) }

  context 'validation' do
    context 'requires' do
      before(:each) {
        biological_association.valid?
      }

      specify 'biological_relationship' do
        expect(biological_association.errors.include?(:biological_relationship)).to be_truthy
      end

      specify 'biological_association_subject' do
        expect(biological_association.errors.include?(:biological_association_subject)).to be_truthy
      end

      specify 'biological_association_object' do
        expect(biological_association.errors.include?(:biological_association_object)).to be_truthy
      end

    end
  end

  context 'concerns' do
    it_behaves_like 'citations'
    it_behaves_like 'is_data'
  end

end

