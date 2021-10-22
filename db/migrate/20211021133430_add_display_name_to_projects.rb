class AddDisplayNameToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :display_name, :string
  end
end
