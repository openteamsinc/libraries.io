# frozen_string_literal: true

class ProjectGroupIdentifier::Repository < ProjectGroupIdentifier::Base
  private_class_method def self.extract_data(source)
    source
      .pluck(:id, :repository_id)
      .group_by { |repository| repository[1] }
      .select { |_, value| value.size > 1 }
      .map { |key, value| { attributes: { repository_id: key }, projects: value.transpose[0] } }
  end

  private_class_method def self.bulk_data_source
    Project.where.not(repository_id: nil)
  end

  def self.individual_data_source(project)
    return Project.none unless project.repository_id

    Project.where(repository_id: project.repository_id)
  end
end
