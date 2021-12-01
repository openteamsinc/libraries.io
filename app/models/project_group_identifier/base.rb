# frozen_string_literal: true

class ProjectGroupIdentifier::Base
  def self.check_affiliation(project)
    individual_data_source(project)
    extract_data
    update_groups
  end

  def self.populate
    bulk_data_source
    extract_data
    update_groups
  end

  private_class_method def self.update_groups
    @data_source.each do |group|
      attributes = group[:attributes]

      project_group = ProjectGroup.find_or_initialize_by(attributes)
      project_group.update!(attributes)

      project_ids = group[:projects] - project_group.project_ids
      project_group.projects << Project.where(id: project_ids) if project_ids.present?
    end
  end

  private_class_method def self.extract_data
    raise NotImplementedError
  end

  private_class_method def self.bulk_data_source
    raise NotImplementedError
  end

  private_class_method def self.individual_data_source(project)
    raise NotImplementedError
  end
end
