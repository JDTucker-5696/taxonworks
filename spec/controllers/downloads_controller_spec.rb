require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.
#
# Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem.

RSpec.describe DownloadsController, type: :controller, group: [:downloads] do
  before(:each) {
    sign_in
  }

  # TODO: Avoid having to merge file_path when factory already provides this
  let(:valid_attributes) {
    strip_housekeeping_attributes(FactoryBot.build(:valid_download).attributes.merge({ source_file_path: Rails.root.join('spec/files/downloads/Sample.zip') }))
  }
  let(:valid_attributes_no_file) {
    strip_housekeeping_attributes(FactoryBot.build(:valid_download_no_file).attributes)
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # DownloadsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET list" do
    it "with no other parameters, assigns a page of @downloads" do
      o = Download.create! valid_attributes
      get :list, params: {}, session: valid_session
      expect(assigns(:downloads)).to include(o)
    end

    it 'renders the list template' do
      get :list, params: {}, session: valid_session
      expect(response).to render_template('list')
    end
  end

  describe "GET #index" do
    it "assigns downloads to @recent_objects" do
      o = Download.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:recent_objects)).to include(o)
    end
  end

  describe "GET #show" do
    it 'assigns the requested download as @download' do
      o = Download.create! valid_attributes
      get :show, params: {id: o.to_param}, session: valid_session
      expect(assigns(:download)).to eq(o)
    end
  end

  describe "GET #download_file" do
    context "download is ready" do
      let(:download) { Download.create! valid_attributes }

      it "sends the requested file" do
        get :file, params: {id: download.to_param}, session: valid_session
        expect(response.body).to eq(IO.binread(download.file_path))
      end

      it "increments the download counter" do
        3.times { get :file, params: {id: download.to_param}, session: valid_session }
        expect(download.reload.times_downloaded).to eq(3)
      end
    end

    context "download is not ready" do
      let(:download_no_file) { Download.create! valid_attributes_no_file }

      it "redirects to #show" do
        get :file, params: {id: download_no_file.to_param}, session: valid_session
        expect(response).to redirect_to(download_url)
      end
    end
  end

  include_examples 'DELETE #destroy', Download

end
