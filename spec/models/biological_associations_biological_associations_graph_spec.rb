require 'rails_helper'

describe BiologicalAssociationsBiologicalAssociationsGraph, :type => :model do

  let(:biological_associations_biological_associations_graph) { FactoryBot.build(:biological_associations_biological_associations_graph) } 


  context "validation" do
    context "requires" do
      before(:each) {
        biological_associations_biological_associations_graph.valid?
      }      

      specify "biological_associations_graph" do
        expect(biological_associations_biological_associations_graph.errors.include?(:biological_associations_graph)).to be_truthy
      end

      specify "biological_association" do
        expect(biological_associations_biological_associations_graph.errors.include?(:biological_association)).to be_truthy
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
