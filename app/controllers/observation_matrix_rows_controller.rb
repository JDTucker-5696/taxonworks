class ObservationMatrixRowsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_matrix_row, only: [:show]

  # GET /matrices
  # GET /matrices.json
  def index
    @recent_objects = ObservationMatrixRow.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /matrix_rows/1
  # GET /matrix_rows/1.json
  def show
  end

  def list
    @observation_matrix_rows = ObservationMatrixRow.with_project_id(sessions_current_project_id).page(params[:page])
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_matrix_row
    @observation_matrix_row = ObservationMatrixRow.find(params[:id])
  end

end
