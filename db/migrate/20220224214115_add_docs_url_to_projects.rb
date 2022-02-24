class AddDocsUrlToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :docs_url, :string
  end
end
