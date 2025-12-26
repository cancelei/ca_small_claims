# frozen_string_literal: true

class Category < ApplicationRecord
  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: :parent_id, dependent: :destroy
  has_many :form_definitions, dependent: :nullify
  has_many :workflows, dependent: :nullify

  scope :roots, -> { where(parent_id: nil) }
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :name) }

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validate :max_two_levels

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  def root?
    parent_id.nil?
  end

  def child?
    parent_id.present?
  end

  def full_path
    parent ? "#{parent.slug}/#{slug}" : slug
  end

  def display_name
    parent ? "#{parent.name} > #{name}" : name
  end

  private

  def max_two_levels
    errors.add(:parent, "only 2 levels allowed") if parent&.parent_id.present?
  end

  def generate_slug
    self.slug = name.parameterize
  end
end
