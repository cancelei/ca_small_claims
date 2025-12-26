# frozen_string_literal: true

class SubmissionsController < ApplicationController
  include SessionStorage

  before_action :set_submission, only: [:show, :destroy, :pdf, :download_pdf]

  def index
    @submissions = if current_user
      current_user.submissions.includes(:form_definition).recent
    else
      Submission.for_session(form_session_id).includes(:form_definition).recent
    end
  end

  def show
    @form_definition = @submission.form_definition
    @field_definitions = @form_definition.field_definitions.by_position
  end

  def destroy
    form_code = @submission.form_definition.code
    @submission.destroy

    redirect_to submissions_path, notice: "Submission for #{form_code} deleted."
  end

  def pdf
    begin
      pdf_path = @submission.generate_pdf

      send_file pdf_path,
        type: "application/pdf",
        disposition: "inline",
        filename: pdf_filename
    rescue StandardError => e
      Rails.logger.error "PDF generation failed: #{e.message}"
      redirect_to submission_path(@submission),
        alert: "PDF generation failed."
    end
  end

  def download_pdf
    begin
      pdf_path = @submission.generate_flattened_pdf

      send_file pdf_path,
        type: "application/pdf",
        disposition: "attachment",
        filename: pdf_filename
    rescue StandardError => e
      Rails.logger.error "PDF generation failed: #{e.message}"
      redirect_to submission_path(@submission),
        alert: "PDF generation failed."
    end
  end

  private

  def set_submission
    @submission = Submission.find(params[:id])

    unless can_access_submission?(@submission)
      redirect_to submissions_path, alert: "Submission not found."
    end
  end

  def pdf_filename
    form_code = @submission.form_definition.code
    timestamp = Time.current.strftime("%Y%m%d")
    "#{form_code}_#{timestamp}.pdf"
  end
end
