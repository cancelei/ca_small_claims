# frozen_string_literal: true

class FieldDefinition < ApplicationRecord
  belongs_to :form_definition

  validates :name, presence: true, uniqueness: { scope: :form_definition_id }
  validates :pdf_field_name, presence: true
  validates :field_type, presence: true, inclusion: { in: %w[
    text textarea tel email date currency
    checkbox checkbox_group radio select
    signature repeating_group address
  ] }

  scope :required, -> { where(required: true) }
  scope :in_section, ->(section) { where(section: section) }
  scope :by_position, -> { order(:section, :position) }
  scope :on_page, ->(page) { where(page_number: page) }

  def repeatable?
    repeating_group.present?
  end

  def conditional?
    conditions.present? && conditions.any?
  end

  def has_options?
    options.present? && options.any?
  end

  def width_class
    case width
    when "half" then "w-full md:w-1/2"
    when "third" then "w-full md:w-1/3"
    when "quarter" then "w-full md:w-1/4"
    when "two_thirds" then "w-full md:w-2/3"
    else "w-full"
    end
  end

  def input_type
    case field_type
    when "tel" then "tel"
    when "email" then "email"
    when "currency" then "number"
    when "date" then "date"
    else "text"
    end
  end

  def component_name
    "Forms::#{field_type.camelize}FieldComponent"
  end
end
