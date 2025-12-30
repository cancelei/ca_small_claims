# frozen_string_literal: true

class WorkflowStep < ApplicationRecord
  include ConditionalSupport

  belongs_to :workflow
  belongs_to :form_definition

  validates :position, presence: true, uniqueness: { scope: :workflow_id }

  scope :required, -> { where(required: true) }
  scope :optional, -> { where(required: false) }
  scope :ordered, -> { order(:position) }

  def display_name
    name.presence || form_definition.title
  end

  # Override ConditionalSupport's should_show? with legacy implementation
  # to maintain backward compatibility with existing operator format
  def should_show?(submission_data)
    return true unless conditional?

    conditions.all? do |condition|
      field = condition["field"]
      operator = condition["operator"] || "equals"
      value = condition["value"]
      actual = submission_data[field]

      case operator
      when "equals" then actual == value
      when "not_equals" then actual != value
      when "present" then actual.present?
      when "blank" then actual.blank?
      when "greater_than" then actual.to_i > value.to_i
      when "includes" then Array(actual).include?(value)
      else true
      end
    end
  end

  def prefill_data(shared_data)
    return {} if data_mappings.blank?

    data_mappings.each_with_object({}) do |(target_field, source_key), result|
      result[target_field] = shared_data[source_key] if shared_data.key?(source_key)
    end
  end
end
