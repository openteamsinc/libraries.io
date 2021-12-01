# frozen_string_literal: true

require 'rails_helper'

describe ProjectGroupIdentifier::Base, type: :model do
  describe '.check_affiliation' do
    it { expect(described_class).to respond_to(:check_affiliation) }

    it 'accepts fixed number of 1 argument' do
      expect(described_class.method(:check_affiliation).arity).to eq 1
    end

    it 'raises NotImplementedError' do
      expect { described_class.check_affiliation(0) }.to raise_error(NotImplementedError)
    end
  end

  describe '.populate' do
    it { expect(described_class).to respond_to(:populate) }

    it 'accepts no arguments' do
      expect(described_class.method(:populate).arity).to be_zero
    end

    it 'raise NotImplementedError' do
      expect { described_class.populate }.to raise_error(NotImplementedError)
    end
  end
end
