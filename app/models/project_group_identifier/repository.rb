# frozen_string_literal: true

class ProjectGroupIdentifier::Repository < ProjectGroupIdentifier::Base
  private_class_method def self.data_source
    Project
      .where.not(repository_id: nil)
      .pluck(:id, :repository_id)
      .group_by { |repository| repository[1] }
      .select { |_, value| value.size > 1 }
      .map { |key, value| { attributes: { repository_id: key }, projects: value.transpose[0] } }
  end
end
