# frozen_string_literal: true

class GithubDownloadUsersWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical, unique: :until_executed

  def perform(users)
    users.each do |user|
      if user[:type] == "Organization"
        RepositoryOrganisation.where(host_type: "GitHub").find_or_create_by(uuid: user[:id]) do |db_user|
          db_user.login = user[:login]
        end
      else
        RepositoryUser.create_from_host("GitHub", user)
      end
    rescue
      nil
    end
  end
end
