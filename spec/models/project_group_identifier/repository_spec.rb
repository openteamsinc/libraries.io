# frozen_string_literal: true

require 'rails_helper'

describe ProjectGroupIdentifier::Repository, type: :model do
  VCR.configure do |c|
    c.allow_http_connections_when_no_cassette = true
  end

  let(:repository) { create :repository }
  let(:project1) { create(:project, repository: repository) }
  let(:project2) { create(:project, repository: repository) }

  describe '.populate' do
    it { expect(described_class).to respond_to(:populate) }

    it 'accepts no arguments' do
      expect(described_class.method(:populate).arity).to be_zero
    end

    it 'returns [] when there is no projects in the db' do
      expect(described_class.populate).to eq []
    end

    it 'returns hash of matching projects by repository_id' do
      expected_response = [{ :attributes=>{ :repository_id=>repository.id }, :projects=>[project1.id, project2.id] }]
      expect(described_class.populate).to eq(expected_response)
    end
  end

  describe '.check_affiliation' do
    let(:project_with_repository) { create(:project, repository: repository) }
    let(:project_without_repository) { create(:project, repository: nil) }

    it { expect(described_class).to respond_to(:check_affiliation) }

    it 'accepts fixed number of 1 argument' do
      expect(described_class.method(:check_affiliation).arity).to eq 1
    end

    it 'returns [] when there are no matching projects by repository_id' do
      expect(described_class.check_affiliation(project_with_repository)).to eq []
    end

    it 'returns [] when project is without repository' do
      expect(described_class.check_affiliation(project_without_repository)).to eq []
    end

    it 'returns hash of matching projects by repository_id' do
      expected_response = [{ :attributes=>{ :repository_id=>repository.id }, :projects=>[project1.id, project2.id].reverse }]
      expect(described_class.check_affiliation(project1)).to eq(expected_response)
    end
  end
end
