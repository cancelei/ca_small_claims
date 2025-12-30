# frozen_string_literal: true

require "rails_helper"

RSpec.describe FormDefinition, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:category).optional }
    it { is_expected.to have_many(:field_definitions).dependent(:destroy) }
    it { is_expected.to have_many(:workflow_steps).dependent(:destroy) }
    it { is_expected.to have_many(:submissions).dependent(:destroy) }
    it { is_expected.to have_many(:session_submissions).dependent(:destroy) }
    it { is_expected.to have_many(:form_feedbacks).dependent(:destroy) }
  end

  describe "validations" do
    # Subject needed for uniqueness test - shoulda-matchers requires a valid record
    subject { build(:form_definition) }

    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:pdf_filename) }
    it { is_expected.to validate_uniqueness_of(:code) }
  end

  describe "#pdf_path" do
    let(:form) { create(:form_definition, pdf_filename: "sc100.pdf") }

    context "when using local storage" do
      before do
        allow(ENV).to receive(:fetch).with("USE_S3_STORAGE", "false").and_return("false")
      end

      it "returns local filesystem path" do
        expect(form.pdf_path).to eq(Rails.root.join("lib", "pdf_templates", "sc100.pdf"))
      end
    end

    context "when using S3 storage" do
      let(:s3_service_double) { instance_double(S3::TemplateService) }
      let(:cached_path) { Rails.root.join("tmp", "cached_templates", "sc100.pdf") }

      before do
        allow(ENV).to receive(:fetch).with("USE_S3_STORAGE", "false").and_return("true")
        allow(S3::TemplateService).to receive(:new).and_return(s3_service_double)
        allow(s3_service_double).to receive(:download_template).with("sc100.pdf").and_return(cached_path)
      end

      it "downloads from S3 and returns cached path" do
        expect(s3_service_double).to receive(:download_template).with("sc100.pdf")

        result = form.pdf_path

        expect(result).to eq(cached_path)
      end
    end
  end

  describe "#pdf_exists?" do
    let(:form) { create(:form_definition, pdf_filename: "sc100.pdf") }

    context "when using local storage" do
      before do
        allow(ENV).to receive(:fetch).with("USE_S3_STORAGE", "false").and_return("false")
      end

      it "checks local filesystem" do
        allow(File).to receive(:exist?).with(Rails.root.join("lib", "pdf_templates", "sc100.pdf")).and_return(true)

        expect(form.pdf_exists?).to be true
      end
    end

    context "when using S3 storage" do
      let(:s3_service_double) { instance_double(S3::TemplateService) }

      before do
        allow(ENV).to receive(:fetch).with("USE_S3_STORAGE", "false").and_return("true")
        allow(S3::TemplateService).to receive(:new).and_return(s3_service_double)
      end

      it "checks S3 for template existence" do
        allow(s3_service_double).to receive(:template_exists?).with("sc100.pdf").and_return(true)

        expect(form.pdf_exists?).to be true
      end

      it "returns false when template not in S3" do
        allow(s3_service_double).to receive(:template_exists?).with("sc100.pdf").and_return(false)

        expect(form.pdf_exists?).to be false
      end
    end
  end

  describe "#generation_strategy" do
    it "returns :form_filling for fillable PDFs" do
      form = create(:form_definition, fillable: true)
      expect(form.generation_strategy).to eq(:form_filling)
    end

    it "returns :html_generation for non-fillable PDFs" do
      form = create(:form_definition, fillable: false)
      expect(form.generation_strategy).to eq(:html_generation)
    end
  end

  describe "#can_generate_pdf?" do
    context "for fillable forms" do
      let(:form) { create(:form_definition, fillable: true, pdf_filename: "sc100.pdf") }

      it "returns true if PDF exists" do
        allow(form).to receive(:pdf_exists?).and_return(true)
        expect(form.can_generate_pdf?).to be true
      end

      it "returns false if PDF does not exist" do
        allow(form).to receive(:pdf_exists?).and_return(false)
        expect(form.can_generate_pdf?).to be false
      end
    end

    context "for non-fillable forms" do
      let(:form) { create(:form_definition, fillable: false) }

      it "returns true if HTML template exists" do
        allow(form).to receive(:html_template_exists?).and_return(true)
        expect(form.can_generate_pdf?).to be true
      end

      it "returns false if HTML template does not exist" do
        allow(form).to receive(:html_template_exists?).and_return(false)
        expect(form.can_generate_pdf?).to be false
      end
    end
  end
end
