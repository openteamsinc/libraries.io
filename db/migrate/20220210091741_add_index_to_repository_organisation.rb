class AddIndexToRepositoryOrganisation < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :repository_organisations, [:login, :host_type], algorithm: :concurrently
  end
end
