# frozen_string_literal: true
class ProjectDependentVersionsCountWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical

  def perform
    ProjectDependentVersionsCount.refresh
  end
end
