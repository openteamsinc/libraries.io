class AddIndexToIssues < ActiveRecord::Migration[5.2]
  def change
    add_index :issues, :uuid
  end
end
