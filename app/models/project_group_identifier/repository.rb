# frozen_string_literal: true

class ProjectGroupIdentifier::Repository < ProjectGroupIdentifier::Base
  private_class_method def self.bulk_data_source
    @data_source = Project.where.not(repository_id: nil)
  end

  private_class_method def self.individual_data_source(project)
    repo_id = project.repository_id
    @data_source = Project.none and return unless repo_id

    @data_source = Project.where(repository_id: repo_id)
  end

  private_class_method def self.extract_data
    @data_source = @data_source
      .pluck(:id, :repository_id)
      .group_by { |repository| repository[1] }
      .select { |_, value| value.size > 1 }
      .map { |key, value| { attributes: { repository_id: key }, projects: value.transpose[0] } }
  end
end
