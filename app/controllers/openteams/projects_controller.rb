class Openteams::ProjectsController < Openteams::ApplicationController
  before_action :find_project

  def update
    @project.update!(project_params)
    render json: @project
  end

  private

  def project_params
    params.require(:project).permit(:display_name, :youtube_url, :twitter_url)
  end
end
