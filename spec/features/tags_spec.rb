require 'rails_helper'

describe 'Tags', :type => :feature do
  let(:index_path) { tags_path }
  let(:page_index_name) { 'tags' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project

      o  = Otu.create!(name: 'Cow', by: @user, project: @project)
      ce = CollectingEvent.create!(verbatim_label: 'Collecting a cow', by: @user, project: @project)

      keywords = []
      ['slow', 'medium', 'fast'].each do |n|
        keywords.push FactoryGirl.create(:valid_keyword, name: n, by: @user, project: @project)
      end

      (0..2).each do |i|
        Tag.create!(tag_object: o, keyword: keywords[i], by: @user, project: @project)
      end
    }

    describe 'GET /tags' do
      before { visit tags_path }

      it_behaves_like 'a_data_model_with_annotations_index'
    end

    describe 'GET /tags/list' do
      before { visit list_tags_path }

      it_behaves_like 'a_data_model_with_standard_list'
    end

    # pending 'clicking a tag link anywhere renders the tagged object in <some> view'

    describe 'the structure of tag_splat' do
      specify 'has a splat' do
        ce = CollectingEvent.first
        visit("#{ce.class.name.tableize}/#{ce.id}")
        expect(find("#tag_splat_#{ce.class.name}_#{ce.id}").value).to have_text('*')
      end
    end
  end
end
