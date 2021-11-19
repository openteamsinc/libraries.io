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

  private_class_method def self.project_group_identifier(identifier)
    [IDENTIFIERS.fetch(identifier, IDENTIFIERS.values)].flatten
  end
end
