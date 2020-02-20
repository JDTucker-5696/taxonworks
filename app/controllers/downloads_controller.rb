class DownloadsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_download, only: [:show, :download_file, :destroy, :update, :api_file, :api_show]

  # GET /downloads
  # GET /downloads.json
  def index
    @recent_objects = Download.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /downloads/1
  def show
  end

  # DELETE /downloads/1
  # DELETE /downloads/1.json
  def destroy
    @download.destroy
    respond_to do |format|
      format.html { redirect_to downloads_url, notice: 'Download was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # PATCH /downloads/1
  # PATCH /downloads/1.json
  def update
    @download.update(download_params)
    render action: :show
  end

  # GET /downloads/list
  # GET /downloads/list.json
  def list
    @downloads = Download.where(project_id: sessions_current_project_id).order(:id).page(params[:page]).per(params[:per])
  end

  # GET /downloads/1/download_file
  def download_file
    if @download.ready?
      @download.increment!(:times_downloaded)
      send_file @download.file_path
    else
      redirect_to download_url
    end
  end

  def api_index
    @downloads = Download.where(is_public: true, project_id: sessions_current_project_id) # .page(params[:page]).per([ [(params[:per] || 100).to_i, 1000].min, 1].max)
    render '/downloads/api/index.json.jbuilder'
  end

  def api_file
    send_file @download.file_path
  end

  def api_show
    render '/downloads/api/show.json.jbuilder'
  end

  private

  def set_download
    @download = Download.unscoped.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def download_params
    params.require(:download).permit(:is_public)
  end
end
