# frozen_string_literal: true

# Provides conditional visibility logic for models that have a `conditions`
# attribute (typically a JSON/JSONB column storing an array of condition objects).
#
# Condition objects have the format:
#   { "field" => "some_field", "operator" => "equals", "value" => "expected_value" }
#
# @example Including in a model
#   class FieldDefinition < ApplicationRecord
#     include ConditionalSupport
#   end
#
# @example Usage
#   field.conditional?  # => true if conditions are present
#   step.should_show?({ "employment_status" => "employed" })  # => true/false
#
module ConditionalSupport
  extend ActiveSupport::Concern

  # Supported operators for condition evaluation
  OPERATORS = %w[
    equals
    not_equals
    present
    blank
    greater_than
    less_than
    includes
    not_includes
    matches
  ].freeze

  # Checks if this record has any conditions defined
  #
  # @return [Boolean] true if conditions array is present and non-empty
  def conditional?
    conditions.present? && conditions.any?
  end

  # Evaluates all conditions against provided data
  #
  # @param data [Hash] The data to evaluate conditions against
  # @return [Boolean] true if all conditions pass (or no conditions exist)
  def should_show?(data)
    return true unless conditional?

    conditions.all? do |condition|
      evaluate_condition(condition, data)
    end
  end

  # Evaluates all conditions, returning true if any condition passes
  #
  # @param data [Hash] The data to evaluate conditions against
  # @return [Boolean] true if any condition passes (or no conditions exist)
  def should_show_any?(data)
    return true unless conditional?

    conditions.any? do |condition|
      evaluate_condition(condition, data)
    end
  end

  private

  # Evaluates a single condition against the provided data
  #
  # @param condition [Hash] The condition to evaluate
  # @param data [Hash] The data to evaluate against
  # @return [Boolean] true if the condition passes
  def evaluate_condition(condition, data)
    field = condition["field"] || condition[:field]
    operator = condition["operator"] || condition[:operator] || "equals"
    expected = condition["value"] || condition[:value]
    actual = data[field] || data[field.to_s] || data[field.to_sym]

    case operator.to_s
    when "equals"
      actual == expected
    when "not_equals"
      actual != expected
    when "present"
      actual.present?
    when "blank"
      actual.blank?
    when "greater_than"
      actual.to_i > expected.to_i
    when "less_than"
      actual.to_i < expected.to_i
    when "includes"
      Array(actual).include?(expected)
    when "not_includes"
      !Array(actual).include?(expected)
    when "matches"
      actual.to_s.match?(Regexp.new(expected.to_s, Regexp::IGNORECASE))
    else
      # Unknown operator - default to true (permissive)
      true
    end
  rescue StandardError => e
    Rails.logger.warn "ConditionalSupport: Failed to evaluate condition #{condition.inspect}: #{e.message}"
    true # Default to showing on error
  end
end
