# frozen_string_literal: true

require 'rails_helper'

describe ProjectGroup, type: :model do
  before do
    @identifiers = {
      by_repository: ProjectGroupIdentifier::Repository,
      by_repository_url: ProjectGroupIdentifier::RepositoryUrl
    }
  end

  it 'has a IDENTIFIERS constant' do
    expect(described_class::IDENTIFIERS).to be_a(Hash)
    expect(described_class::IDENTIFIERS).not_to be_empty
    expect(described_class::IDENTIFIERS).to eq @identifiers
  end

  it { should belong_to(:repository) }

  it { should have_many(:projects) }
  
  describe '.populate' do
    it { expect(described_class).to respond_to(:populate) }

    it 'accepts variable number of 1 argument' do
      expect(described_class.method(:populate).arity).to eq(-1)
    end
  end

  describe '.check_affiliation' do
    it { expect(described_class).to respond_to(:check_affiliation) }

    it 'accepts variable number of 2 arguments' do
      expect(described_class.method(:check_affiliation).arity).to eq(-2)
    end

    it 'raise error if project not found' do
      expect { described_class.check_affiliation(-1) }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  describe 'identifier argument behaviour' do
    it 'returns all ProjectGroupIdentifiers when using :all' do
      expect(described_class.populate(:all)).to eq @identifiers.values
    end

    it 'returns specified ProjectGroupIdentifier by method argument' do
      expect(described_class.populate(@identifiers.keys.last)).to eq [@identifiers.values.last]
    end
  end
end
