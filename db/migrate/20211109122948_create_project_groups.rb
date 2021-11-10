class CreateProjectGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :project_groups do |t|
      t.string :name
      t.references :repository, foreign_key: true

      t.timestamps
    end
  end
end
