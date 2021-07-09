#forzen_string_literal: true
require 'rails_helper'

describe RepositoryUpdateStargazersCountWorker do
  it 'should use low priority queue' do
    is_expected.to be_processed_in :repo
  end

  it 'should update repository stars counter' do
    repo_name = 'rails/rails'
    expect(Repository).to receive(:update_stargazers_count).with(repo_name)
    subject.perform(repo_name)
  end
end
