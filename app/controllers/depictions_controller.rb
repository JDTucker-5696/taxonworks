class DepictionsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_depiction, only: [:show, :edit, :update, :destroy]

  # GET /depictions
  # GET /depictions.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = Depiction.where(project_id: sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @depictions = Depiction.where(project_id: sessions_current_project_id).where(filter_params)
      }
    end
  end

  def list
    @depictions = Depiction.where(project_id: sessions_current_project_id).page(params[:page])
  end

  # GET /depictions/1
  # GET /depictions/1.json
  def show
  end

  # GET /depictions/new
  def new
    @depiction = Depiction.new
  end

  # GET /depictions/1/edit
  def edit
  end

  # POST /depictions
  # POST /depictions.json
  def create
    @depiction = Depiction.new(depiction_params)
    respond_to do |format|
      if @depiction.save
        format.html { redirect_to @depiction, notice: 'Depiction was successfully created.' }
        format.json { render :show, status: :created, location: @depiction }
      else
        format.html { render :new }
        format.json { render json: @depiction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /depictions/1
  # PATCH/PUT /depictions/1.json
  def update
    respond_to do |format|
      if @depiction.update(depiction_params)
        format.html { redirect_to @depiction, notice: 'Depiction was successfully updated.' }
        format.json { render :show, status: :ok, location: @depiction }
      else
        format.html { render :edit }
        format.json { render json: @depiction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /depictions/1
  # DELETE /depictions/1.json
  def destroy
    @depiction.destroy
    respond_to do |format|
      format.html { redirect_to depictions_url, notice: 'Depiction was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # PATCH /sort?depiction_ids[]=1&depiction_ids[]=2.json
  def sort
    begin 
      params.require(:depiction_ids).each_with_index do |d|
        i.update_column(:position, i + 1)
      end
    rescue ActionController::ParameterMissing  
      format.json { render json: {success: false}, status: :unprocessable_entity and return }
    rescue ActiveRecord::RecordInvalid
      format.json { render json: {success: false}, status: :unprocessable_entity and return }
    end

    format.json { render json: {success: true}, status: :ok and return }
  end

  private 

  # handle the polymorphic resource
  def filter_params
    h = params.permit(
      :content_id
    ).to_h
    if h.size > 1 
      respond_to do |format|
        format.html { render plain: '404 Not Found', status: :unprocessable_entity and return }
        format.json { render json: {success: false}, status: :unprocessable_entity and return }
      end
    end

    model = h.keys.first.split('_').first.classify
    return {depiction_object_type: model, depiction_object_id: h.values.first}
  end

  # def depiction_object
  #   filter_params[:depiction_object_type].find(filter_params[:depiction_object_id])
  # end

  def set_depiction
    @depiction = Depiction.find(params[:id])
  end

  def depiction_params
    params.require(:depiction).permit(:depiction_object_id, :depiction_object_type, :caption, :figure_label, image_attributes: [:image_file])
  end

end
