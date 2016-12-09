require 'rails_helper'
require 'lib/soft_validation_helpers'

describe 'SoftValidation', group: :soft_validation do

  context 'extended class methods' do

    specify '.has_self_soft_validations?' do
      expect(Softy.has_self_soft_validations?).to be_falsey
    end

    specify '.soft_validation_methods' do
      expect(Softy.soft_validation_methods).to eq('Softy' => {})
    end

    context 'accessing soft_validations' do
      specify '.soft_validators() returns individual methods from soft_validation_methods' do
        expect(Softy.soft_validators).to eq([])
      end
    end

    context 'describing soft_validations' do
      specify '.soft_validation_descriptions returns name and description pairs' do
        expect(Softy.soft_validation_descriptions).to eq({})
      end
    end

    context 'adding soft validations' do
      before(:each) {
        Softy.reset_soft_validation!
      }

      specify 'basic use: soft_validate(:method)' do
        expect(Softy.soft_validate(:haz_cheezburgers?)).to be_truthy
        expect(Softy.soft_validation_methods['Softy'].keys).to contain_exactly(:haz_cheezburgers?)
      end

      specify 'assigment to a named set of validations: soft_validate(:method, set: :set_name)' do
        expect(Softy.soft_validate(:needs_moar_cheez?, set: :cheezy)).to be_truthy
        expect(Softy.soft_validation_sets['Softy'][:all]).to contain_exactly(:needs_moar_cheez?)
        expect(Softy.soft_validation_sets['Softy'][:cheezy]).to contain_exactly(:needs_moar_cheez?)
      end

      specify 'assigment with name, description, resolution' do
        expect(Softy.soft_validate(:needs_moar_cheez?, name: 'Check for cheeze', description: 'Open bun, look for cheeze.', resolution: [:root_path])).to be_truthy
        expect(Softy.soft_validation_methods['Softy'][:needs_moar_cheez?].name).to eq('Check for cheeze') 
        expect(Softy.soft_validation_methods['Softy'][:needs_moar_cheez?].description).to eq('Open bun, look for cheeze.') 
        expect(Softy.soft_validation_methods['Softy'][:needs_moar_cheez?].resolution).to contain_exactly(:root_path) 
      end
    end

    context 'soft_validations between classes' do
      before(:each) {
        Softy.reset_soft_validation!
        OtherSofty.reset_soft_validation!
      }

      specify 'methods assigned to parent are available to child' do
        Softy.soft_validate(:yucky_cheezburgers?)
        expect(OtherSofty.soft_validators).to include(:yucky_cheezburgers?)
      end

      specify 'methods assigned to child are not merged with parents' do
        OtherSofty.soft_validate(:haz_cheezburgers?)
        expect(Softy.soft_validation_sets['Softy'][:all]).to contain_exactly()
      end

      context 'accessed via soft_validators' do
        specify 'soft_validator returns a single instance of the method when method assigned to parent' do
          Softy.soft_validate(:haz_cheezburgers?)
          expect(Softy.soft_validators).to contain_exactly(:haz_cheezburgers?)
          expect(OtherSofty.soft_validators).to contain_exactly(:haz_cheezburgers?)
        end

        specify 'soft_validator returns a single instance of the method when method assigned to child' do
          OtherSofty.soft_validate(:haz_cheezburgers?)
          expect(Softy.soft_validators).to contain_exactly()
          expect(OtherSofty.soft_validators).to contain_exactly(:haz_cheezburgers?)
        end
      end

      # specify 'methods assigned to one class are not available to another' do
      #   expect(Softy.soft_validate(:haz_cheezburgers?)).to be_truthy
      #   expect(Softy.soft_validation_methods[:all]).to eq([:haz_cheezburgers?])
      #   expect(OtherSofty.soft_validation_methods[:all]).to eq([])
      #   expect(OtherSofty.soft_validate(:foo)).to be_truthy
      #   expect(OtherSofty.soft_validation_methods[:all]).to eq([:foo])
      #   expect(Softy.soft_validation_methods[:all]).to eq([:haz_cheezburgers?])
      # end
    end
  end

  context 'extended instance methods' do
    let(:softy) {Softy.new}

    specify 'soft_validate' do
      expect(softy).to respond_to(:soft_validate)
    end

    specify 'soft_valid?' do
      expect(softy).to respond_to(:soft_valid?)
    end

    specify 'clear_soft_validations' do
      expect(softy).to respond_to(:clear_soft_validations)
    end

    specify 'fix_soft_validations' do
      expect(softy).to respond_to(:fix_soft_validations)
    end
  end

  context 'example usage' do
    before do
      Softy.reset_soft_validation!
    end

    context 'with a validation that has resolution' do
      before {
        Softy.soft_validate(:just_bun?, resolution: [:root_path])
        Softy.soft_validate(:needs_moar_cheez?)
      }

      let(:softy) {Softy.new}

      specify 'soft_validations#resolution_for()' do
        expect(softy.soft_validations.resolution_for(:just_bun?)).to contain_exactly(:root_path)
      end

      specify 'soft_validations#resolution_for()' do
        expect(softy.soft_validations.resolution_for(:needs_moar_cheez?)).to contain_exactly()
      end
    end

    context 'with a couple of validations' do
      before do 
        # Stub the validation methods 
        Softy.soft_validate(:needs_moar_cheez?, set: :cheezy)
        Softy.soft_validate(:haz_cheezburgers?)
      end 

      let(:softy) {Softy.new}

      specify '.has_self_soft_validations?' do
        expect(Softy.has_self_soft_validations?).to be_truthy
      end

      specify 'softy.soft_valid?' do
        expect(softy.soft_valid?).to be_falsey
      end

      specify 'softy.soft_validated?' do
        expect(softy.soft_validated?).to be_falsey
        softy.soft_validate
        expect(softy.soft_validated?).to be_truthy
      end

      context 'instances after soft_validate' do
        let(:softy) { Softy.new }

        before(:each) {
          softy.soft_validate
        }

        specify 'softy.soft_validations' do
          expect(softy.soft_validations.class).to eq(SoftValidation::SoftValidations)
        end

        specify '#fixes_run?' do
          expect(softy.soft_validations.fixes_run?).to be_falsey
        end

        specify 'softy.fix_soft_validations(:some_bad_value)' do
          expect{softy.fix_soft_validations(:some_bad_value)}.to raise_error(RuntimeError, /invalid scope/)
        end

        specify 'softy.fix_soft_validations' do
          expect(softy.soft_validations.on(:mohr).size).to eq(1)
          expect(softy.fix_soft_validations).to be_truthy
          expect(softy.soft_validations.fixes_run?).to eq(:automatic)
          expect(softy.soft_validations.fix_messages).to eq(base: ['no longer hungry, cooked a cheezeburger'], mohr: ["fix not run, no automatic fix available"])

          # TODO: Move out  
          expect(softy.soft_validations.on(:mohr).size).to eq(1)
          expect(softy.soft_validations.messages).to eq(["hungry (for cheez)!", "hungry!"] ) 
          expect(softy.soft_validations.messages_on(:mohr)).to eq(['hungry (for cheez)!'] ) 
        end

        specify 'softy.fix_soft_validations(:requested)' do
          expect(softy.soft_validations.on(:mohr).size).to eq(1)
          expect(softy.fix_soft_validations(:requested)).to be_truthy
          expect(softy.soft_validations.fixes_run?).to eq(:requested) 
          expect(softy.soft_validations.fix_messages).to eq(mohr: ["fix not run, no automatic fix available"], base: ['fix available, but not triggered'])
        end

      end
    end
  end
end


