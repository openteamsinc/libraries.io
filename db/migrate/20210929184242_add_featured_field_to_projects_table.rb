class AddFeaturedFieldToProjectsTable < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :projects, :featured, :boolean, default: false
    add_index  :projects, :featured, algorithm: :concurrently
  end
end
