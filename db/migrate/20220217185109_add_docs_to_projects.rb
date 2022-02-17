class AddDocsToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :docs, :text
  end
end
