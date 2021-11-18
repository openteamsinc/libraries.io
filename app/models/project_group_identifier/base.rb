# frozen_string_literal: true

class ProjectGroupIdentifier::Base
  def self.populate
    data_source.each do |group|
      attributes = group[:attributes]

      project_group = ProjectGroup.find_or_initialize_by(attributes)
      project_group.update!(attributes)

      project_ids = group[:projects] - project_group.project_ids
      project_group.projects << Project.where(id: project_ids) if project_ids.present?
    end
  end

  private_class_method def self.data_source
    raise NotImplementedError
  end
end
