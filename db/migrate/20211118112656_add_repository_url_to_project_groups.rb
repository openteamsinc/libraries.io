class AddRepositoryUrlToProjectGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :project_groups, :repository_url, :string
  end
end
