class AddProjectGroupToProject < ActiveRecord::Migration[5.2]
  def change
    add_reference :projects, :project_group, foreign_key: true
  end
end
