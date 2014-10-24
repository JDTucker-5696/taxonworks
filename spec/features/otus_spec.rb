require 'rails_helper'

# :base_class is defined by us, it is accessible as example.metadata[:base_class].  It's used 
describe 'Otus', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { otus_path }
    let(:page_index_name) { 'Otus' }
  end

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project
      10.times { factory_girl_create_for_user_and_project(:valid_otu, @user, @project) }
    }

    describe 'GET /otus' do
      before {
        sign_in_user_and_select_project
        visit otus_path
      }

      specify 'the features of an index page' do
        expect(page).to have_content('Otus')
        expect(page).to have_link('New')
        expect(page).to have_link('List')
        expect(page).to have_link('Download')
      end

      specify 'that it has an AJAX autocomplete box' do # js: true 
        expect(page).to have_button('Show')
        expect(page).to have_field('Enter a search for Otus')

        fill_in('Enter a search for Otus', :with => 'a')
      end
    end

    describe 'GET /otus/list' do
      before do
        visit list_otus_path
      end

      specify 'that it renders without error' do
        expect(page).to have_content 'Listing Otus'
      end

      specify "there to be 'First', 'Prev', 'Next', and 'Last' links" do
      # click_link('Next')
      # expect(page).to have_link('First')
      # expect(page).to have_link('Prev')
      # expect(page).to have_link('Next')
      # expect(page).to have_link('Last')
      end

    end

    describe 'GET /otus/n' do
      before {
        visit otu_path(Otu.second)
      }

      specify 'there is a \'previous\' link' do
        expect(page).to have_link('Previous')
      end

      specify 'there is a \'next\' link' do
        expect(page).to have_link('Next')
      end

    end
  end
end
