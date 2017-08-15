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

describe NotesController, :type => :controller do
  before(:each) {
    sign_in 
  }

  # This should return the minimal set of attributes required to create a valid
  # Note. As you add validations to Note be sure to
  # adjust the attributes here as well.

  let(:o) {FactoryGirl.create(:valid_otu)}
  let(:valid_attributes) {
    {note_object_id: o.id, note_object_type: o.class.to_s, text: "Just the fax"}  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # NotesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns recent notes as @recent_objects" do
      note = Note.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:recent_objects)).to include(note)
    end
  end

  before {
    request.env['HTTP_REFERER'] = list_otus_path # logical example
  }

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Note" do
        expect {
          post :create, params: {note: valid_attributes}, session: valid_session
        }.to change(Note, :count).by(1)
      end

      it "assigns a newly created note as @note" do
        post :create, params: {note: valid_attributes}, session: valid_session
        expect(assigns(:note)).to be_a(Note)
        expect(assigns(:note)).to be_persisted
      end

      it "redirects to :back" do
        post :create, params: {note: valid_attributes}, session: valid_session
        # expect(response).to redirect_to(list_otus_path)
        expect(response).to redirect_to(otu_path(o))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved note as @note" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Note).to receive(:save).and_return(false)
        post :create, params: {note: {"text" => "invalid value"}}, session: valid_session
        expect(assigns(:note)).to be_a_new(Note)
      end

      it "re-renders the :back template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Note).to receive(:save).and_return(false)
        post :create, params: {note: {"text" => "invalid value"}}, session: valid_session
        expect(response).to redirect_to(list_otus_path)
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested note" do
        note = Note.create! valid_attributes
        # Assuming there are no other notes in the database, this
        # specifies that the Note created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        update_params = ActionController::Parameters.new({text: "MyString"}).permit(:text)
        expect_any_instance_of(Note).to receive(:update).with(update_params)
        put :update, params: {id: note.to_param, note: {"text" => "MyString"}}, session: valid_session
      end

      it "assigns the requested note as @note" do
        note = Note.create! valid_attributes
        put :update, params: {id: note.to_param, note: valid_attributes}, session: valid_session
        expect(assigns(:note)).to eq(note)
      end

      it "redirects to :back" do
        note = Note.create! valid_attributes
        put :update, params: {id: note.to_param, note: valid_attributes}, session: valid_session
        expect(response).to redirect_to(otu_path(o))
      end
    end

    describe "with invalid params" do
      it "assigns the note as @note" do
        note = Note.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Note).to receive(:save).and_return(false)
        update_params = ActionController::Parameters.new({text: "invalid value"}).permit(:text)
        put :update, params: {id: note.to_param, note: update_params}, session: valid_session
        expect(assigns(:note)).to eq(note)
      end

      it "re-renders the :back template" do
        note = Note.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Note).to receive(:save).and_return(false)
        put :update, params: {id: note.to_param, note: {"text" => "invalid value"}}, session: valid_session
        expect(response).to redirect_to(list_otus_path)
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested note" do
      note = Note.create! valid_attributes
      expect {
        delete :destroy, params: {id: note.to_param}, session: valid_session
      }.to change(Note, :count).by(-1)
    end

    it "redirects to :back" do
      note = Note.create! valid_attributes
      delete :destroy, params: {id: note.to_param}, session: valid_session
      expect(response).to redirect_to(list_otus_path)
    end
  end

end
