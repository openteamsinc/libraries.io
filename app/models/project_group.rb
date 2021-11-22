# frozen_string_literal: true
class ProjectGroup < ApplicationRecord
  IDENTIFIERS = {
    by_repository: ProjectGroupIdentifier::Repository,
    by_repository_url: ProjectGroupIdentifier::RepositoryUrl,
  }.freeze

  belongs_to :repository
  has_many :projects, dependent: :nullify

  def self.populate(identifier = :all)
    project_group_identifier(identifier).each(&:populate)
  end

  def self.check_affiliation(project_id, identifier = :all)
    project = Project.find(project_id)
    return unless project

    project_group_identifier(identifier).each { |pg| pg.check_affiliation(project) }
  end

  private_class_method def self.project_group_identifier(identifier)
    [IDENTIFIERS.fetch(identifier, IDENTIFIERS.values)].flatten
  end
end
