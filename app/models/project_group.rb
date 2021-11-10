# frozen_string_literal: true:
class ProjectGroup < ApplicationRecord
  belongs_to :repository
  has_many :projects, dependent: :nullify

  def self.populate_all
    data = Project
      .where.not(repository_id: nil)
      .pluck(:id, :repository_id)
      .group_by { |repo| repo[1] }
      .map { |key, value| [key, value.size, value] }
      .select { |item| item[1] > 1 }
      .map { |item| [item[0], item[2].transpose[0]] }

    data.each do |item|
      repository_id, project_ids = item
      project_group = ProjectGroup.find_or_initialize_by(repository_id: repository_id)
      repository = Repository.find(repository_id)
      project_group.update!(name: repository.full_name.titleize) unless project_group.name.present?

      project_ids -= project_group.project_ids
      project_group.projects << Project.where(id: project_ids)
    end
  end
end
