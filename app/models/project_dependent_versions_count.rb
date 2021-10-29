# frozen_string_literal: true
class ProjectDependentVersionsCount < ApplicationRecord

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  private

  def readonly?
    true
  end
end
