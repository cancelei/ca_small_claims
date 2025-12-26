# frozen_string_literal: true

class Submission < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :form_definition
  belongs_to :workflow, optional: true

  validates :status, inclusion: { in: %w[draft completed submitted] }

  scope :drafts, -> { where(status: "draft") }
  scope :completed, -> { where(status: "completed") }
  scope :submitted, -> { where(status: "submitted") }
  scope :for_session, ->(sid) { where(session_id: sid) }
  scope :in_workflow, ->(wid) { where(workflow_session_id: wid) }
  scope :recent, -> { order(updated_at: :desc) }

  before_create :set_defaults

  def anonymous?
    user_id.nil?
  end

  def field_value(field_name)
    form_data[field_name.to_s]
  end

  def update_field(field_name, value)
    self.form_data = form_data.merge(field_name.to_s => value)
    save
  end

  def update_fields(new_data)
    self.form_data = form_data.merge(new_data.stringify_keys)
    save
  end

  def complete!
    update!(status: "completed", completed_at: Time.current)
  end

  def submit!
    update!(status: "submitted")
  end

  def draft?
    status == "draft"
  end

  def completed?
    status == "completed"
  end

  def generate_pdf
    Pdf::FormFiller.new(self).generate
  end

  def generate_flattened_pdf
    Pdf::FormFiller.new(self).generate_flattened
  end

  def shared_data
    form_definition.field_definitions
      .where.not(shared_field_key: nil)
      .each_with_object({}) do |field, hash|
        value = field_value(field.name)
        hash[field.shared_field_key] = value if value.present?
      end
  end

  def completion_percentage
    return 0 if form_definition.required_fields.empty?

    filled = form_definition.required_fields.count do |field|
      field_value(field.name).present?
    end

    (filled.to_f / form_definition.required_fields.count * 100).round
  end

  private

  def set_defaults
    self.workflow_session_id ||= SecureRandom.uuid if workflow_id.present?
  end
end
