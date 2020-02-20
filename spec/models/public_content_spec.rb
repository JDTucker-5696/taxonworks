require 'rails_helper'

describe PublicContent, type: :model do
  let(:public_content) {FactoryBot.build(:public_content) }

  context 'validation' do
    before(:each) {
      public_content.valid?
    }

    context 'requires' do
      specify 'topic_id' do
        expect(public_content.errors.include?(:topic_id)).to be_truthy
      end
      specify 'text' do
        expect(public_content.errors.include?(:text)).to be_truthy
      end
    end
  end

end
