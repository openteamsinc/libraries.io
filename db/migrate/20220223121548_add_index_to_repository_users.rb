class AddIndexToRepositoryUsers < ActiveRecord::Migration[5.2]
  def change
    add_index :repository_users, :uuid
  end
end
