# frozen_string_literal: true

class ProjectUpdatePercentileWorker
  include Sidekiq::Worker
  sidekiq_options queue: :score, unique: :until_executed

  def perform
    PercentileCalculator.update_percentiles
  end
end
