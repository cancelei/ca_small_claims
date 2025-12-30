# frozen_string_literal: true

require "rails_helper"

RSpec.describe PdfHandling, type: :controller do
  # Create a test controller that includes the concern
  controller(ApplicationController) do
    include PdfHandling

    def preview
      @submission = Submission.find(params[:id])
      send_pdf_inline(@submission)
    end

    def download
      @submission = Submission.find(params[:id])
      send_pdf_download(@submission)
    end

    def preview_with_custom_filename
      @submission = Submission.find(params[:id])
      send_pdf_inline(@submission, filename: "custom_preview.pdf")
    end

    def download_unflattened
      @submission = Submission.find(params[:id])
      send_pdf_download(@submission, flattened: false)
    end
  end

  before do
    routes.draw do
      get "preview/:id" => "anonymous#preview"
      get "download/:id" => "anonymous#download"
      get "preview_with_custom_filename/:id" => "anonymous#preview_with_custom_filename"
      get "download_unflattened/:id" => "anonymous#download_unflattened"
      # Add forms route for redirect
      get "forms/:id" => "anonymous#show", as: :form
      root to: "anonymous#index"
    end
  end

  let(:form_definition) { create(:form_definition) }
  let(:submission) { Submission.create!(form_definition: form_definition, status: "draft", form_data: {}) }
  let(:pdf_path) { Rails.root.join("tmp", "test.pdf").to_s }

  before do
    # Create a test PDF file
    FileUtils.mkdir_p(File.dirname(pdf_path))
    File.write(pdf_path, "%PDF-1.4 test content")
  end

  after do
    FileUtils.rm_f(pdf_path)
  end

  describe "#send_pdf_inline" do
    context "when PDF generation succeeds" do
      before do
        allow_any_instance_of(Submission).to receive(:generate_pdf).and_return(pdf_path)
      end

      it "sends the PDF with inline disposition" do
        get :preview, params: { id: submission.id }

        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Type"]).to eq("application/pdf")
        expect(response.headers["Content-Disposition"]).to include("inline")
      end

      it "uses preview filename format" do
        get :preview, params: { id: submission.id }

        expect(response.headers["Content-Disposition"]).to include("#{form_definition.code}_preview.pdf")
      end
    end

    context "with custom filename" do
      before do
        allow_any_instance_of(Submission).to receive(:generate_pdf).and_return(pdf_path)
      end

      it "uses the custom filename" do
        get :preview_with_custom_filename, params: { id: submission.id }

        expect(response.headers["Content-Disposition"]).to include("custom_preview.pdf")
      end
    end

    context "when PDF generation fails" do
      before do
        allow_any_instance_of(Submission).to receive(:generate_pdf)
          .and_raise(StandardError.new("Template not found"))
      end

      it "redirects with an error message" do
        get :preview, params: { id: submission.id }

        # The concern redirects to form_path when available
        expect(response).to be_redirect
        expect(flash[:alert]).to include("PDF generation failed")
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with(/PDF generation failed/)
        expect(Rails.logger).to receive(:error).at_least(:once) # backtrace

        get :preview, params: { id: submission.id }
      end
    end
  end

  describe "#send_pdf_download" do
    context "when PDF generation succeeds" do
      before do
        allow_any_instance_of(Submission).to receive(:generate_flattened_pdf).and_return(pdf_path)
      end

      it "sends the PDF with attachment disposition" do
        get :download, params: { id: submission.id }

        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Type"]).to eq("application/pdf")
        expect(response.headers["Content-Disposition"]).to include("attachment")
      end

      it "uses download filename format with date" do
        get :download, params: { id: submission.id }

        expect(response.headers["Content-Disposition"]).to include("#{form_definition.code}_#{Date.current}.pdf")
      end

      it "generates flattened PDF by default" do
        expect_any_instance_of(Submission).to receive(:generate_flattened_pdf).and_return(pdf_path)

        get :download, params: { id: submission.id }
      end
    end

    context "with flattened: false" do
      before do
        allow_any_instance_of(Submission).to receive(:generate_pdf).and_return(pdf_path)
      end

      it "generates non-flattened PDF" do
        expect_any_instance_of(Submission).to receive(:generate_pdf).and_return(pdf_path)
        expect_any_instance_of(Submission).not_to receive(:generate_flattened_pdf)

        get :download_unflattened, params: { id: submission.id }
      end
    end

    context "when PDF generation fails" do
      before do
        allow_any_instance_of(Submission).to receive(:generate_flattened_pdf)
          .and_raise(StandardError.new("PDFTK not available"))
      end

      it "redirects with an error message" do
        get :download, params: { id: submission.id }

        # The concern redirects to form_path when available
        expect(response).to be_redirect
        expect(flash[:alert]).to include("PDF generation failed")
      end

      it "truncates long error messages" do
        long_message = "A" * 200
        allow_any_instance_of(Submission).to receive(:generate_flattened_pdf)
          .and_raise(StandardError.new(long_message))

        get :download, params: { id: submission.id }

        expect(flash[:alert].length).to be <= 130 # "PDF generation failed: " + 100 chars
      end
    end
  end

  describe "#generate_pdf_filename" do
    let(:controller_instance) { controller }

    it "generates preview filename for inline disposition" do
      filename = controller_instance.send(:generate_pdf_filename, submission, :inline)
      expect(filename).to eq("#{form_definition.code}_preview.pdf")
    end

    it "generates download filename with date for attachment disposition" do
      filename = controller_instance.send(:generate_pdf_filename, submission, :attachment)
      expect(filename).to eq("#{form_definition.code}_#{Date.current}.pdf")
    end
  end

  describe "#pdf_failure_redirect_path" do
    let(:controller_instance) { controller }

    it "returns form_path when form_path helper is available" do
      path = controller_instance.send(:pdf_failure_redirect_path, submission)
      # The concern uses form_path when available
      expect(path).to include("/forms/")
    end
  end
end
