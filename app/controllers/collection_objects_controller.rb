class CollectionObjectsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_collection_object, only: [:show, :edit, :update, :destroy, :depictions]

  # GET /collection_objects
  # GET /collection_objects.json
  def index
    @recent_objects = CollectionObject.recent_from_project_id($project_id).order(updated_at: :desc).includes(:identifiers, :taxon_determinations).limit(10)
    render '/shared/data/all/index'
  end

  # GET /collection_objects/1
  # GET /collection_objects/1.json
  def show
    @images = params[:include] == ["images"] ? @collection_object.images : nil
  end

  # GET /collection_objects/depictions/1
  # GET /collection_objects/depictions/1.json
  def depictions
  end

  # GET /collection_objects/by_identifier/ABCD
  def by_identifier
    @identifier = params.require(:identifier)
    @request_project_id = sessions_current_project_id
    @collection_objects = CollectionObject.with_identifier(@identifier).where(project_id: @request_project_id).all

    raise ActiveRecord::RecordNotFound if @collection_objects.empty?
  end

  # GET /collection_objects/new
  def new
    @collection_object = CollectionObject.new
  end

  # GET /collection_objects/1/edit
  def edit
  end

  # POST /collection_objects
  # POST /collection_objects.json
  def create
    @collection_object = CollectionObject.new(collection_object_params)

    respond_to do |format|
      if @collection_object.save
        format.html { redirect_to @collection_object.metamorphosize, notice: 'Collection object was successfully created.' }
        format.json { render action: 'show', status: :created, location: @collection_object.metamorphosize }
      else
        format.html { render action: 'new' }
        format.json { render json: @collection_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collection_objects/1
  # PATCH/PUT /collection_objects/1.json
  def update
    respond_to do |format|
      if @collection_object.update(collection_object_params)
        @collection_object = @collection_object.metamorphosize
        format.html { redirect_to @collection_object, notice: 'Collection object was successfully updated.' }
        format.json {  respond_with_bip(@collection_object)  }
        #   format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { respond_with_bip(@collection_object)  }
#        format.json { render json: @collection_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collection_objects/1
  # DELETE /collection_objects/1.json
  def destroy
    @collection_object.destroy
    respond_to do |format|
      format.html { redirect_to collection_objects_url }
      format.json { head :no_content }
    end
  end

  # GET /collection_objects/list
  def list
    @collection_objects = CollectionObject.with_project_id($project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  # GET /collection_object/search
  def search
    if params[:id].blank?
      redirect_to collection_object_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to collection_object_path(params[:id])
    end
  end

  def autocomplete
    @collection_objects = CollectionObject.find_for_autocomplete(params.merge(project_id: sessions_current_project_id)) # in model
    data = @collection_objects.collect do |t|
      {id: t.id,
       label: ApplicationController.helpers.collection_object_tag(t), # in helper
       response_values: {
           params[:method] => t.id
       },
       label_html: ApplicationController.helpers.collection_object_tag(t) # render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end
    render :json => data
  end

  # GET /collection_objects/download
  def download
    send_data CollectionObject.generate_download(CollectionObject.where(project_id: $project_id)), type: 'text', filename: "collection_objects_#{DateTime.now.to_s}.csv"
  end

  private

  def set_collection_object
    @collection_object = CollectionObject.with_project_id($project_id).find(params[:id])
    @recent_object = @collection_object 
  end

  def collection_object_params
    params.require(:collection_object).permit(
      :total, :preparation_type_id, :repository_id,
      :ranged_lot_category_id, :collecting_event_id,
      :buffered_collecting_event, :buffered_deteriminations,
      :buffered_other_labels, :deaccessioned_at, :deaccession_reason,
      collecting_event_attributes: [ ] 
    )
  end

end
