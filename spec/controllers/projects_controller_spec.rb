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

describe ProjectsController, :type => :controller do
  before(:each) {
    sign_in_administrator # TODO: !! this needs to be sign_in_administrator !!
  }

  # This should return the minimal set of attributes required to create a valid
  # Georeference. As you add validations to Georeference be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {{ name: 'Project for controller', without_root_taxon_name: true }}

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ProjectsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all projects as @projects" do
      project = Project.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:projects)).to include(Project.find(1), project)
    end
  end

  describe "GET show" do
    it "assigns the requested project as @project" do
      project = Project.create! valid_attributes
      get :show, params: {id: project.to_param}, session: valid_session
      expect(assigns(:project)).to eq(project)
    end
  end

  describe "GET new" do
    it "assigns a new project as @project" do
      get :new, params: {}, session: valid_session
      expect(assigns(:project)).to be_a_new(Project)
    end
  end

  describe "GET edit" do
    it "assigns the requested project as @project" do
      project = Project.create! valid_attributes
      get :edit, params: {id: project.to_param}, session: valid_session
      expect(assigns(:project)).to eq(project)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Project" do
        expect {
          post :create, params: {project: valid_attributes}, session: valid_session
        }.to change(Project, :count).by(1)
      end

      it "assigns a newly created project as @project" do
        post :create, params: {project: valid_attributes}, session: valid_session
        expect(assigns(:project)).to be_a(Project)
        expect(assigns(:project)).to be_persisted
      end

      it "redirects to the created project" do
        post :create, params: {project: valid_attributes}, session: valid_session
        expect(response).to redirect_to(Project.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved project as @project" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Project).to receive(:save).and_return(false)
        post :create, params: {project: {"name" => "invalid value"}}, session: valid_session
        expect(assigns(:project)).to be_a_new(Project)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Project).to receive(:save).and_return(false)
        post :create, params: {project: {"name" => "invalid value"}}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested project" do
        project = Project.create! valid_attributes
        # Assuming there are no other projects in the database, this
        # specifies that the Project created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        update_params = ActionController::Parameters.new({name: "MyString"}).permit(:name)
        expect_any_instance_of(Project).to receive(:update).with(update_params)
        put :update, params: {id: project.to_param, project: update_params}, session: valid_session
      end

      it "assigns the requested project as @project" do
        project = Project.create! valid_attributes
        put :update, params: {id: project.to_param, project: valid_attributes}, session: valid_session
        expect(assigns(:project)).to eq(project)
      end

      it "redirects to the project" do
        project = Project.create! valid_attributes
        put :update, params: {id: project.to_param, project: valid_attributes}, session: valid_session
        expect(response).to redirect_to(project)
      end
    end

    describe "with invalid params" do
      it "assigns the project as @project" do
        project = Project.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Project).to receive(:save).and_return(false)
        put :update, params: {id: project.to_param, project: {"name" => "invalid value"}}, session: valid_session
        expect(assigns(:project)).to eq(project)
      end

      it "re-renders the 'edit' template" do
        project = Project.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Project).to receive(:save).and_return(false)
        put :update, params: {id: project.to_param, project: {"name" => "invalid value"}}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    #  it "destroys the requested project" do
    #    project = Project.create! valid_attributes
    #    expect {
    #      delete :destroy, params: {id: project.to_param}, session: valid_session
    #    }.to change(Project, :count).by(-1)
    #  end

    it "redirects to the projects list" do
      project = Project.create! valid_attributes
      delete :destroy, params: {id: project.to_param}, session: valid_session
      expect(response).to redirect_to(projects_url)
    end
  end

end
