# frozen_string_literal: true

class PercentileCalculator
  attr_accessor :fields, :ids, :percentiles

  def self.update_percentiles(fields = %i[rank score])
    new(*fields)
      .update_percentiles
      .store_percentile_tables
  end

  def self.update_percentiles_for_project(project, fields = %i[rank score])
    percentile_values = {}
    fields.each do |field|
      field_value = (project.read_attribute(field) || 0).to_s
      percentile_values[field_percentile_name(field)] = begin
        JSON.parse(REDIS.get(field_percentile_key(field)))
      rescue TypeError
        new(*fields).store_percentile_tables
        retry
      end[field_value] || 0
     project.update_columns(percentile_values)
    end
  end

  def self.field_percentile_name(field)
    "#{field}_percentile"
  end

  def self.field_percentile_key(field)
    "project_#{field}_percentile"
  end

  def initialize(*fields)
    @fields = fields
    @ids = {}
    map_ids(Project.all.pluck(:id, *fields))
    @percentiles = {}
    calculate_percentiles
  end

  def update_percentiles
    fields.each do |field|
      ids[field].each do |rank, ids|
        ProjectUpdatePercentilesWorker.perform_async(ids, PercentileCalculator.field_percentile_name(field) => percentiles[field][rank])
      end
    end
    self
  end

  def store_percentile_tables
    percentiles.each do |field, table|
      REDIS.set(PercentileCalculator.field_percentile_key(field), table.to_json)
    end
  end

  private

  def calculate_percentiles
    fields.each do |field|
      table = ids[field].map { |k, v| [k, v.size] }.to_h
      table.keys.max.times { |index| table[index] ||= 0 }
      table = table.sort
      table.map!.with_index { |a, index| [a[0], index.zero? ? a[1] : a[1] + table[index - 1][1]] }
      n = table.last[1].to_f
      percentiles[field] = table.map { |a| [a[0], ((a[1] / n) * 100).round] }.to_h
    end
  end

  def map_ids(collection)
    fields.each_with_index do |field, index|
      ids[field] = collection
        .map { |fields| [fields[0], fields[index + 1] || 0] }
        .sort_by { |fields| fields[1] }
        .group_by { |fields| fields[1] }
        .transform_values { |a| a.map(&:first) }
    end
  end
end
