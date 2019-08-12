class ObservationMatrixRowsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_matrix_row, only: [:show]

  # GET /observation_matrix_rows.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = ObservationMatrixRow.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @observation_matrix_rows = ObservationMatrixRow.where(filter_params).where(project_id: sessions_current_project_id).per(params[:per]).page(params[:page])
      }
    end
  end

  # GET /observation_matrix_rows/1
  # GET /observation_matrix_rows/1.json
  def show
  end

  def list
    @observation_matrix_rows = ObservationMatrixRow.where(project_id: sessions_current_project_id).page(params[:page])
  end

  # POST /observation_matrix_rows/sort?id[]=1&id[]=2
  def sort
    ObservationMatrixRow.sort(params.require(:ids))
    head :no_content 
  end

  private
  
  def set_matrix_row
    @observation_matrix_row = ObservationMatrixRow.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def filter_params
    params.permit(:observation_matrix_id, :collection_object_id, :otu_id)
  end
end
