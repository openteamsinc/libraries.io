module MaintenanceStats
  module Queries
    module Github
      class IssuesQuery < BaseQuery
        ISSUES_QUERY = Rails.application.config.graphql.client.parse <<-GRAPHQL
          query($owner: String!, $repo_name: String!, $one_year: GitTimestamp!){
            repository(owner: $owner, name: $repo_name){
              openIssues: issues(states: OPEN, filterBy:{since:$one_year}) {
                totalCount
              },
              closedIssues:issues(states:CLOSED, filterBy:{since:$one_year}){
                totalCount
              },
              openPrs:pullRequests(states:OPEN){
                totalCount
              },
              closedPrs:pullRequests(states:CLOSED){
                totalCount
              }
            }
          }
        GRAPHQL


        VALID_PARAMS = [:owner, :repo_name, :start_date]
        REQUIRED_PARAMS = [:owner, :repo_name, :start_date]

        def self.client_type
          :v4
        end

        def query(params: {})
          validate_params(params)
          # figure out the one year ago
          params[:one_year] = (params[:start_date] - 1.year).iso8601

          @client.query(ISSUES_QUERY, variables: params)
        end
      end
    end
  end
end
