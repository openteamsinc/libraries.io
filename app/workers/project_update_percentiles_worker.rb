# frozen_string_literal: true

class ProjectUpdatePercentilesWorker
  include Sidekiq::Worker
  sidekiq_options queue: :score, unique: :until_executed

  def perform(ids, *args)
    Project.where(id: ids).update_all(*args)
  end
end
