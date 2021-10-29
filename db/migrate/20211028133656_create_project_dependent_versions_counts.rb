class CreateProjectDependentVersionsCounts < ActiveRecord::Migration[5.2]
  def change
    create_view :project_dependent_versions_counts, materialized: true
    add_index :project_dependent_versions_counts, :project_id
  end
end
