# frozen_string_literal: true

module Percentile
  extend ActiveSupport::Concern

  def update_percentiles(fields = %i[rank score])
    PercentileCalculator.update_percentiles_for_project(self, fields)
  end

  class_methods do
    def update_percentiles(fields = %i[rank score])
      PercentileCalculator.update_percentiles(fields)
    end
  end
end
