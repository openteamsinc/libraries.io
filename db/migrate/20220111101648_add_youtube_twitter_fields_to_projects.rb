class AddYoutubeTwitterFieldsToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :youtube_url, :string
    add_column :projects, :twitter_url, :string
  end
end
