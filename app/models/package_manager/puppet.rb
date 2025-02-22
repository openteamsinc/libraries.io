# frozen_string_literal: true

module PackageManager
  class Puppet < Base
    HAS_VERSIONS = true
    HAS_DEPENDENCIES = true
    BIBLIOTHECARY_SUPPORT = false
    BIBLIOTHECARY_PLANNED = true
    URL = "https://forge.puppet.com"
    COLOR = "#302B6D"

    def self.project_names
      offset = 0
      projects = []
      loop do
        results = get_json("https://forgeapi.puppetlabs.com/v3/modules?limit=100&offset=#{offset}")["results"].map { |result| result["slug"] }
        break if results == []

        projects += results
        offset += 100
      end
      projects
    end

    def self.project(name)
      get_json("https://forgeapi.puppetlabs.com/v3/modules/#{name}")
    end

    def self.mapping(raw_project)
      current_release = raw_project["current_release"]
      metadata = current_release&.fetch("metadata", {})
      {
        name: raw_project&.fetch("slug"),
        repository_url: metadata&.fetch("source", nil),
        description: metadata&.fetch("description", nil),
        keywords_array: current_release&.fetch("tags", nil),
        licenses: metadata&.fetch("license", nil),
      }
    end

    def self.versions(raw_project, _name)
      raw_project["releases"].map do |release|
        {
          number: release["version"],
          published_at: release["created_at"],
        }
      end
    end

    def self.dependencies(name, version, _mapped_project)
      release = get_json("https://forgeapi.puppetlabs.com/v3/releases/#{name}-#{version}")
      metadata = release["metadata"]
      metadata["dependencies"].map do |dependency|
        {
          project_name: dependency["name"].sub("/", "-"),
          requirements: dependency["version_requirement"],
          kind: "runtime",
          platform: self.name.demodulize,
        }
      end
    end

    def self.recent_names
      get_json("https://forgeapi.puppetlabs.com/v3/modules?limit=100&sort_by=latest_release")["results"].map { |result| result["slug"] }
    end

    def self.install_instructions(project, version = nil)
      "puppet module install #{project.name}" + (version ? " --version #{version}" : "")
    end

    def self.package_link(project, version = nil)
      "https://forge.puppet.com/#{project.name.sub('-', '/')}" + (version ? "/#{version}" : "")
    end

    def self.download_url(name, version = nil)
      "https://forge.puppet.com/v3/files/#{name}-#{version}.tar.gz"
    end
  end
end
