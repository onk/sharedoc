class PresentationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:index, :show]

  def index
    @presentations = @user.presentations.all
  end

  def show
    @presentation = @user.presentations.find(params[:id])
  end

  def create
    presentation = current_user.presentations.create(presentation_params)
    Ppt2pdfJob.perform_later(presentation)
    redirect_to presentation_path(current_user.username, presentation)
  end

  def search
    search_param = { "query": { "match_phrase": { "body": params[:q] } } }
    presentation_ids = PresentationOutline.search(search_param).map(&:presentation_id)
    @presentations = Presentation.find(presentation_ids)
    render "index"
  end

  private

    def set_user
      @user = User.find_by!(username: params[:username])
    end

    def presentation_params
      params.require(:presentation).permit(:original_file)
    end
end
