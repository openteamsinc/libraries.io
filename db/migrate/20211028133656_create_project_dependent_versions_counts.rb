class CreateProjectDependentVersionsCounts < ActiveRecord::Migration[5.2]
  def change
    create_view :project_dependent_versions_counts, materialized: true
  end
end
