class AddIndexToRepository < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :repositories, :full_name, algorithm: :concurrently
  end
end
