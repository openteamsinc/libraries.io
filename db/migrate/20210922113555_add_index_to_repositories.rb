class AddIndexToRepositories < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :repositories, [:host_type, :full_name], algorithm: :concurrently
  end
end
