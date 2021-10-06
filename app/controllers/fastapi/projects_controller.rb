class Fastapi::ProjectsController < Fastapi::ApplicationController
  before_action :find_project

  def feature
    @project.update!(featured: true)
    render json: { message: 'Project featured' }, status: :ok
  end

  def unfeature
    @project.update(featured: false)
    render json: { message: 'Project unfeatured' }, status: :ok
  end

  private

  def find_project
    @project = Project.find(params[:id])
  end
end
