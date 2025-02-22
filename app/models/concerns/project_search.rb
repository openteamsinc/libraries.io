# frozen_string_literal: true
module ProjectSearch
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    index_name "projects-#{Rails.env}"

    FIELDS = ['name^2', 'exact_name^2', 'extra_searchable_names^2', 'repo_name', 'description', 'homepage', 'language', 'keywords_array', 'normalized_licenses', 'platform']

    settings index: { number_of_shards: 3, number_of_replicas: 1 } do
      mapping do
        indexes :name, type: 'text', analyzer: 'snowball', boost: 6
        indexes :exact_name, type: 'text', analyzer: 'snowball', boost: 2
        indexes :extra_searchable_names, type: 'text', index: :true, boost: 2

        indexes :description, type: 'text', analyzer: 'snowball'
        indexes :homepage, type: 'text'
        indexes :repository_url, type: 'text'
        indexes :repo_name, type: 'text'
        indexes :latest_release_number, type: 'text', analyzer: 'keyword'
        indexes :keywords_array, type: 'text', analyzer: 'keyword' do
          indexes :raw, type: 'keyword'
        end
        indexes :language, type: 'text', analyzer: 'keyword' do
          indexes :raw, type: 'keyword'
        end
        indexes :normalized_licenses, type: 'text', analyzer: 'keyword' do
          indexes :raw, type: 'keyword'
        end
        indexes :platform, type: 'text', analyzer: 'keyword' do
          indexes :raw, type: 'keyword'
        end
        indexes :status, type: 'text', analyzer: 'snowball'

        indexes :created_at, type: 'date'
        indexes :updated_at, type: 'date'
        indexes :latest_release_published_at, type: 'date'

        indexes :rank, type: 'integer'
        indexes :stars, type: 'integer'
        indexes :dependents_count, type: 'integer'
        indexes :dependent_repos_count, type: 'integer'
        indexes :contributions_count, type: 'integer'
        indexes :display_name, type: 'text' do
          indexes :raw, type: 'keyword'
        end
        indexes :project_group, type: 'integer'
      end
    end

    after_commit lambda { __elasticsearch__.index_document if previous_changes.any? }, on: [:create, :update], prepend: true
    after_commit lambda { __elasticsearch__.delete_document rescue nil }, on: :destroy

    def as_indexed_json(_options = {})
      as_json(methods: [:stars, :repo_name, :exact_name, :extra_searchable_names, :contributions_count, :dependent_repos_count, :logo_url, :forks, :host_type, :pushed, :wiki, :pages, :subscribers, :size])
    end

    def size
      repository.try(:size)
    end

    def subscribers
      repository.try(:subscribers_count)
    end

    def pages
      repository.try(:has_pages)
    end

    def wiki
      repository.try(:has_wiki)
    end

    def pushed
      repository.try(:pushed_at)
    end

    def host_type
      repository.try(:host_type)
    end

    def forks
      repository.try(:forks_count)
    end

    def dependent_repos_count
      read_attribute(:dependent_repos_count) || 0
    end

    def logo_url
      repository.try(:logo_url)
    end

    def exact_name
      name
    end

    def extra_searchable_names
      if platform == "Maven"
        name.split(":")
      elsif platform == "Clojars"
        name.split("/")
      else
        []
      end
    end

    def marshal_dump
      instance_variables.reject{|m| :__elasticsearch__ == m}.inject({}) do |vars, attr|
        vars[attr] = instance_variable_get(attr)
        vars
      end
    end

    def marshal_load(hash)
      hash.each do |attr, value|
        instance_variable_set(attr, value)
      end
    end

    def self.facets(options = {})
      Rails.cache.fetch "facet:#{options.to_s.gsub(/\W/, '')}", expires_in: 1.hour, race_condition_ttl: 2.minutes do
        search('', options).response.aggregations
      end
    end

    def self.cta_search(filters, options = {})
      facet_limit = options.fetch(:facet_limit, 36)
      options[:filters] ||= []
      search_definition = {
        query: {
          bool: {
            must: { match_all: {} },
            filter:{ bool: filters }
          }
        },
        aggs: facets_options(facet_limit, options),
        filter: { bool: { must: [] } },
        sort: [{'contributions_count' => 'asc'}, {'rank' => 'desc'}]
      }
      search_definition[:filter][:bool][:must] = filter_format(options[:filters])
      __elasticsearch__.search(search_definition)
    end

    def self.bus_factor_search(options = {})
      cta_search({
        must: [
          { range: { contributions_count: { lte: 5, gte: 1 } } }
        ],
        must_not: [
          { term: { "status" => "Hidden" } },
          { term: { "status" => "Removed" } },
          { term: { "status" => "Unmaintained" } }
        ]
      }, options)
    end

    def self.unlicensed_search(options = {})
      cta_search({
        must_not: [
          { exists: { field: "normalized_licenses" } },
          { term: { "status" => "Hidden" } },
          { term: { "status" => "Removed" } },
          { term: { "status" => "Unmaintained" } }
        ]
      }, options)
    end

    def self.facets_options(facet_limit, options)
      {
        language: {
          aggs: {
            language: {
              terms: {
                field: "language",
                size: facet_limit
              },
            }
          },
          filter: {
            bool: {
              must: filter_format(options[:filters], :language)
            }
          }
        },
        licenses: {
          aggs:{
            licenses:{
              terms: {
                field: "normalized_licenses",
                size: facet_limit
              }
            }
          },
          filter: {
            bool: {
              must: filter_format(options[:filters], :normalized_licenses)
            }
          }
        }
      }
    end

    def self.search(query, options = {})
      facet_limit = options.fetch(:facet_limit, 36)
      options[:filters] ||= []
      search_definition = {
        query: {
          function_score: {
            query: {
              bool: {
                must: {
                  match_all: {}
                },
                filter: {
                  bool: {
                    must: [],
                    must_not: [
                      { term: { "status" => "Hidden" } },
                      { term: { "status" => "Removed" } }
                    ]
                  }
                }
              }
            },
            field_value_factor: {
              field: "rank",
              modifier: "square",
              missing: 1
            }
          }
        },
      }

      unless options[:api]
        search_definition[:aggs] = {
          platforms: facet_filter(:platform, facet_limit, options),
          languages: facet_filter(:language, facet_limit, options),
          keywords: facet_filter(:keywords_array, facet_limit, options),
          licenses: facet_filter(:normalized_licenses, facet_limit, options)
        }
        if query.present?
          search_definition[:suggest] = {
            did_you_mean: {
              text: query,
              term: {
                size: 1,
                field: "name"
              }
            }
          }
        end
      end

      search_definition[:sort] = { (options[:sort] || '_score') => (options[:order] || 'desc') }
      search_definition[:query][:function_score][:query][:bool][:filter][:bool][:must] = filter_format(options[:filters])

      if query.present?
        search_definition[:query][:function_score][:query][:bool][:must] = query_options(query, FIELDS)
      elsif options[:sort].blank?
        search_definition[:sort] = [{ 'rank' => 'desc' }, { 'stars' => 'desc' }]
      end

      if options[:prefix].present?
        search_definition[:query][:function_score][:query][:bool][:must] = {
          prefix: { exact_name: original_query },
        }
        search_definition[:sort] = [{ 'rank' => 'desc' }, { 'stars' => 'desc' }]
      end

      __elasticsearch__.search(search_definition)
    end

    def self.query_options(query, fields)
      {
        multi_match: {
          query: query,
          fields: fields,
          fuzziness: 1.2,
          slop: 2,
          type: 'most_fields',
          operator: 'and'
        }
      }
    end

    def self.filter_format(filters, except = nil)
      filters.select { |k, v| v.present? && k != except }.map do |k, v|
        { terms: { k.to_s => v.split(',').first } }
      end
    end

    def self.facet_filter(name, limit, options)
      {
        aggs: {
          name.to_s => {
            terms: {
              field: "#{name}.raw",
              size: limit
            }
          }
        },
        filter: {
          bool: {
            must: filter_format(options[:filters], name.to_sym)
          }
        }
      }
    end
  end
end
