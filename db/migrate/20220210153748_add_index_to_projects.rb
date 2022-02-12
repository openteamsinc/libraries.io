class AddIndexToProjects < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :projects, [:platform, :dependent_repos_count], algorithm: :concurrently
    add_index :projects, [:platform, :id], algorithm: :concurrently
    add_index :projects, :repository_url, algorithm: :concurrently
    add_index :projects, :score, algorithm: :concurrently
  end
end
