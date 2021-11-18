class ChangeProjectGroupsColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :project_groups, :name, :project_name
  end
end
