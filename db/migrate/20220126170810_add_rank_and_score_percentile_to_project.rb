class AddRankAndScorePercentileToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :rank_percentile, :integer
    add_column :projects, :score_percentile, :integer
  end
end
