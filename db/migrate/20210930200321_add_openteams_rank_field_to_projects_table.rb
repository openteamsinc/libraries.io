class AddOpenteamsRankFieldToProjectsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :openteams_rank, :integer, { default: 0, null: false }
  end
end
