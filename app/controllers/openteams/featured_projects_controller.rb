class Openteams::FeaturedProjectsController < Openteams::ApplicationController
  before_action :find_project

  def create
    @project.update!(featured: true)
    render json: { message: 'Project featured' }, status: :ok
  end

  def destroy
    @project.update!(featured: false)
    render json: { message: 'Project unfeatured' }, status: :ok
  end
end
