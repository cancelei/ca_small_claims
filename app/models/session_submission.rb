# frozen_string_literal: true

class SessionSubmission < ApplicationRecord
  include FormDataAccessor

  belongs_to :form_definition

  validates :session_id, presence: true
  validates :expires_at, presence: true

  scope :for_session, ->(sid) { where(session_id: sid) }
  scope :active, -> { where("expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }

  EXPIRATION_HOURS = 72

  before_validation :set_expiration, on: :create

  def expired?
    expires_at <= Time.current
  end

  def extend_expiration!
    update!(expires_at: EXPIRATION_HOURS.hours.from_now)
  end

  class << self
    def cleanup_expired!
      expired.delete_all
    end

    def for_form(session_id, form_definition)
      find_or_initialize_by(
        session_id: session_id,
        form_definition: form_definition
      )
    end
  end

  private

  def set_expiration
    self.expires_at ||= EXPIRATION_HOURS.hours.from_now
  end

  # Called by FormDataAccessor after form_data is updated
  def after_form_data_update
    extend_expiration! if changed?
  end
end
