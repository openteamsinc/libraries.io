# frozen_string_literal: true

class ProjectGroupIdentifier::RepositoryUrl < ProjectGroupIdentifier::Base
  private_class_method def self.bulk_data_source
    @data_source = Project
      .where(repository_id: nil)
      .where.not(repository_url: [nil, ''])
  end

  private_class_method def self.individual_data_source(project)
    repo_url = project.repository_url
    @data_source = Project.none and return unless repo_url

    @data_source = Project.where(repository_id: nil).where(repository_url: repo_url)
  end

  private_class_method def self.extract_data
    @data_source = @data_source
      .pluck(:id, :name, :repository_url)
      .group_by { |project| project[1] }
      .select { |_, value| value.size > 1 }
      .map { |key, value| [key, value.map { |proj| [proj[0], proj[2]] }] }
      .map { |grp| [grp[0], grp[1].group_by { |url| url[1] }.select { |_, value| value.size > 1 }] }
      .reject { |grp| grp[1].empty? }
      .map { |grp| [attributes: { project_name: grp[0], repository_url: grp[1].keys[0] }, projects: grp[1].values[0].transpose[0]] }
      .flatten(1)
  end
end
