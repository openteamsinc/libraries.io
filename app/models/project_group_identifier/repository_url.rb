# frozen_string_literal: true

class ProjectGroupIdentifier::RepositoryUrl < ProjectGroupIdentifier::Base
  private_class_method def self.data_source
    Project
      .where(repository_id: nil)
      .where.not(repository_url: [nil, ''])
      .pluck(:id, :name, :repository_url)
      .group_by { |p| p[1] }
      .select { |_, value| value.size > 1 }
      .map { |key, value| [key, value.map { |proj| [proj[0], proj[2]] }] }
      .map { |grp| [grp[0], grp[1].group_by { |url| url[1] }.select { |_, value| value.size > 1 }] }
      .reject { |a| a[1].empty? }
      .map { |grp| [attributes: { project_name: grp[0], repository_url: grp[1].keys[0] }, projects: grp[1].values[0].transpose[0]] }
      .flatten(1)
  end
end
