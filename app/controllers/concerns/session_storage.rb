# frozen_string_literal: true

module SessionStorage
  extend ActiveSupport::Concern

  included do
    before_action :ensure_session_id
    helper_method :form_session_id, :storage_manager
  end

  private

  def ensure_session_id
    session[:form_session_id] ||= SecureRandom.uuid
  end

  def form_session_id
    session[:form_session_id]
  end

  def storage_manager
    @storage_manager ||= Sessions::StorageManager.new(form_session_id)
  end

  def current_user_or_session
    current_user || form_session_id
  end

  def find_or_create_submission(form_definition, workflow: nil)
    if current_user
      current_user.submissions.find_or_create_by!(
        form_definition: form_definition,
        workflow: workflow,
        status: "draft"
      )
    else
      Submission.find_or_create_by!(
        session_id: form_session_id,
        form_definition: form_definition,
        workflow: workflow,
        status: "draft"
      )
    end
  end

  def can_access_submission?(submission)
    return true if current_user && submission.user_id == current_user.id
    return true if submission.session_id == form_session_id

    false
  end
end
