require 'rails_helper'
require 'lib/soft_validation_helpers'

describe 'SoftValidations', group: :soft_validation do
  let(:soft_validations) {SoftValidation::SoftValidations.new(Softy.new)}

  specify 'add' do
    expect(soft_validations).to respond_to(:add) 
  end

  specify 'add(:invalid_attribute, "message") raises' do
    expect{soft_validations.add(:foo, 'no cheezburgahz!')}.to raise_error(SoftValidation::SoftValidationError, /not a column name/)
  end

  specify 'add(:attribute, "message")' do
    expect(soft_validations.add(:base, 'no cheezburgahz!')).to be_truthy
    expect(soft_validations.soft_validations.count).to eq(1)
  end

  specify 'add(:attribute, "message", fix: :method)' do
    expect(soft_validations.add(:base, 'no cheezburgahz!', fix: 'cook_a_burgah')).to be_truthy
    expect(soft_validations.soft_validations.count).to eq(1)
  end

  specify 'add(:attribute, "message", fix: :method, fix_trigger: :automatic)' do
    expect(soft_validations.add(:base, 'no cheezburgahz!', fix: 'cook_a_burgah', fix_trigger: :automatic)).to be_truthy
    expect(soft_validations.soft_validations.count).to eq(1)
  end

  specify 'add with success/fail message without fix returns false' do
    expect(soft_validations.add(:base,'no cheezburgahz!', success_message: 'cook_a_burgah')).to be_falsey
  end

  specify 'add(:attribute, "message", fix: :method, success_message: "win",  failure_message: "fail")' do
    expect(soft_validations.add(:base, 'no cheezburgahz!', fix: 'cook_a_burgah', success_message: 'haz cheezburger', failure_message: 'no cheezburger')).to be_truthy
  end

  specify 'complete?' do
    soft_validations.validated = true 
    expect(soft_validations.complete?).to be_truthy
  end

  specify 'on' do
    expect(soft_validations).to respond_to(:on)
    expect(soft_validations.on(:base)).to eq([])
  end

  specify 'messages' do
    expect(soft_validations).to respond_to(:messages)
  end

  specify 'messages_on' do
    expect(soft_validations).to respond_to(:messages)
  end

  specify '#resolution_for' do
    expect(soft_validations).to respond_to(:resolution_for)
  end

end

