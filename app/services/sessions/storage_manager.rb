# frozen_string_literal: true

module Sessions
  class StorageManager
    EXPIRATION_HOURS = 72

    attr_reader :session_id

    def initialize(session_id)
      @session_id = session_id
    end

    def save(form_definition, form_data)
      session_sub = SessionSubmission.find_or_initialize_by(
        session_id: @session_id,
        form_definition: form_definition
      )

      session_sub.update!(
        form_data: session_sub.form_data.merge(form_data.stringify_keys),
        expires_at: EXPIRATION_HOURS.hours.from_now
      )

      session_sub
    end

    def load(form_definition)
      SessionSubmission.find_by(
        session_id: @session_id,
        form_definition: form_definition
      )&.form_data || {}
    end

    def find_submission(form_definition)
      SessionSubmission.find_by(
        session_id: @session_id,
        form_definition: form_definition
      )
    end

    def all_data
      SessionSubmission.for_session(@session_id)
        .includes(:form_definition)
        .each_with_object({}) do |sub, hash|
          hash[sub.form_definition.code] = sub.form_data
        end
    end

    def all_submissions
      SessionSubmission.for_session(@session_id).includes(:form_definition)
    end

    def migrate_to_user!(user)
      SessionSubmission.for_session(@session_id).find_each do |session_sub|
        user.submissions.find_or_create_by!(
          form_definition: session_sub.form_definition,
          status: "draft"
        ) do |submission|
          submission.form_data = session_sub.form_data
        end
      end

      clear!
    end

    def clear!
      SessionSubmission.for_session(@session_id).delete_all
    end

    def clear_form!(form_definition)
      SessionSubmission.find_by(
        session_id: @session_id,
        form_definition: form_definition
      )&.destroy
    end

    class << self
      def cleanup_expired!
        count = SessionSubmission.expired.delete_all
        Rails.logger.info "Cleaned up #{count} expired session submissions"
        count
      end
    end
  end
end
