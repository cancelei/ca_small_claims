# frozen_string_literal: true

class FormDefinition < ApplicationRecord
  belongs_to :category, optional: true

  has_many :field_definitions, dependent: :destroy
  has_many :workflow_steps, dependent: :destroy
  has_many :workflows, through: :workflow_steps
  has_many :submissions, dependent: :destroy
  has_many :session_submissions, dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :title, presence: true
  validates :pdf_filename, presence: true

  scope :active, -> { where(active: true) }
  scope :by_category, ->(cat) { joins(:category).where(categories: { slug: cat }) }
  scope :by_category_id, ->(id) { where(category_id: id) }
  scope :ordered, -> { order(:position, :code) }

  # Legacy constant for backward compatibility during migration
  LEGACY_CATEGORIES = %w[filing service pre_trial judgment post_judgment special info plaintiff defendant enforcement appeal collections informational fee_waiver].freeze

  def pdf_path
    Rails.root.join("lib", "pdf_templates", pdf_filename)
  end

  def pdf_exists?
    File.exist?(pdf_path)
  end

  def sections
    field_definitions.group_by(&:section).transform_values { |fields| fields.sort_by(&:position) }
  end

  def required_fields
    field_definitions.where(required: true)
  end

  def shared_field_keys
    field_definitions.where.not(shared_field_key: nil).pluck(:shared_field_key)
  end

  def fields_by_page
    field_definitions.group_by(&:page_number)
  end

  def to_param
    code
  end
end
