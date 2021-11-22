# frozen_string_literal: true

class ProjectGroupAffiliationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, unique: :until_executed

  def perform(project_id, identifier)
    ProjectGroup.check_affiliation(project_id, identifier)
  end
end
