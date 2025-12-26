# frozen_string_literal: true

class FormsController < ApplicationController
  include SessionStorage

  before_action :set_form_definition, only: [:show, :update, :preview, :download]

  def index
    @forms = FormDefinition.active.includes(:category).ordered
    @categories = Category.active.where.not(parent_id: nil).ordered

    if params[:category].present?
      @forms = @forms.by_category(params[:category])
      @current_category = Category.find_by(slug: params[:category])
    end

    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      @forms = @forms.where("LOWER(title) LIKE ? OR LOWER(code) LIKE ? OR LOWER(description) LIKE ?",
        search_term, search_term, search_term)
    end
  end

  def show
    @submission = find_or_create_submission(@form_definition)
    @sections = @form_definition.sections
    @field_definitions = @form_definition.field_definitions.by_position
  end

  def update
    @submission = find_or_create_submission(@form_definition)

    if @submission.update_fields(submission_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "autosave-status",
            partial: "shared/autosave_status",
            locals: { saved_at: Time.current }
          )
        end
        format.html { redirect_to form_path(@form_definition.code), notice: "Form saved" }
      end
    else
      @sections = @form_definition.sections
      @field_definitions = @form_definition.field_definitions.by_position
      render :show, status: :unprocessable_entity
    end
  end

  def preview
    @submission = find_or_create_submission(@form_definition)

    begin
      pdf_path = @submission.generate_pdf

      send_file pdf_path,
        type: "application/pdf",
        disposition: "inline",
        filename: "#{@form_definition.code}_preview.pdf"
    rescue StandardError => e
      Rails.logger.error "PDF generation failed: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      redirect_to form_path(@form_definition.code),
        alert: "PDF generation failed: #{e.message.truncate(100)}"
    end
  end

  def download
    @submission = find_or_create_submission(@form_definition)

    begin
      pdf_path = @submission.generate_flattened_pdf

      send_file pdf_path,
        type: "application/pdf",
        disposition: "attachment",
        filename: "#{@form_definition.code}_#{Date.current}.pdf"
    rescue StandardError => e
      Rails.logger.error "PDF generation failed: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      redirect_to form_path(@form_definition.code),
        alert: "PDF generation failed: #{e.message.truncate(100)}"
    end
  end

  private

  def set_form_definition
    @form_definition = FormDefinition.find_by(code: params[:id].upcase) || FormDefinition.find(params[:id])
  end

  def submission_params
    params.require(:submission).permit!.to_h
  end
end
