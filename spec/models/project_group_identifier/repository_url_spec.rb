# frozen_string_literal: true

require 'rails_helper'

describe ProjectGroupIdentifier::RepositoryUrl, type: :model do
  VCR.configure do |c|
    c.allow_http_connections_when_no_cassette = true
  end

  let(:name) { 'project1' }
  let(:platform1) { 'packagemanager1' }
  let(:platform2) { 'packagemanager2' }
  let(:repository_url) { 'https://example.com' }
  let(:project1) { create(:project, name: name, platform: platform1, repository: nil, repository_url: repository_url) }
  let(:project2) { create(:project, name: name, platform: platform2, repository: nil, repository_url: repository_url) }

  describe '.populate' do
    it { expect(described_class).to respond_to(:populate) }
    
    it 'accepts no arguments' do
      expect(described_class.method(:populate).arity).to be_zero
    end

    it 'returns [] when there is no projects in the db' do
      expect(described_class.populate).to eq []
    end
    
    it 'returns hash of matching projects by name and repository_url' do
      expected_response = [{ :attributes=>{ :project_name=>name, :repository_url=>repository_url }, :projects=>[project1.id, project2.id].reverse }]
      expect(described_class.populate).to eq(expected_response)
    end
  end

  describe '.check_affiliation' do
    let(:project_with_repository_url) { create(:project, name: name, repository: nil, repository_url: repository_url) }
    let(:project_without_repository_url) { create(:project, name: name, repository: nil, repository_url: nil) }

    it { expect(described_class).to respond_to(:check_affiliation) }

    it 'accepts fixed number of 1 argument' do
      expect(described_class.method(:check_affiliation).arity).to eq 1
    end

    it 'returns [] when there are no matching projects by name and repository_url' do
      expect(described_class.check_affiliation(project_with_repository_url)).to eq []
    end

    it 'returns [] when project is without repository' do
      expect(described_class.check_affiliation(project_without_repository_url)).to eq []
    end

    it 'returns hash of matching projects by name and repository_url' do
      expected_response = [{ :attributes=>{ :project_name=>name, :repository_url=>repository_url }, :projects=>[project1.id, project2.id] }]
      expect(described_class.check_affiliation(project1)).to eq(expected_response)
    end
  end
end
