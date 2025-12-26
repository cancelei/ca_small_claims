# frozen_string_literal: true

module Pdf
  class FieldExtractor
    attr_reader :pdf_path

    def initialize(pdf_path)
      @pdf_path = pdf_path.to_s
    end

    def extract
      return [] unless File.exist?(@pdf_path)

      if pdftk_available?
        extract_with_pdftk
      else
        extract_with_hexapdf
      end
    rescue StandardError => e
      Rails.logger.error "PDF field extraction failed: #{e.message}"
      []
    end

    def field_names
      extract.map { |f| f[:name] }
    end

    private

    def pdftk_available?
      system("which pdftk > /dev/null 2>&1") ||
        system("which pdftk-java > /dev/null 2>&1")
    end

    def extract_with_pdftk
      pdftk = PdfForms.new(pdftk_path)
      fields = pdftk.get_fields(@pdf_path)

      fields.map do |field|
        {
          name: field.name,
          type: detect_field_type(field),
          options: field.options,
          value: field.value
        }
      end
    end

    def extract_with_hexapdf
      require "hexapdf"

      doc = HexaPDF::Document.open(@pdf_path)
      fields = []

      doc.acro_form&.each_field do |field|
        fields << {
          name: field.full_field_name,
          type: hexapdf_field_type(field),
          options: field[:Opt]&.to_a,
          value: field.field_value
        }
      end

      fields
    rescue StandardError => e
      Rails.logger.warn "HexaPDF extraction failed: #{e.message}"
      []
    end

    def pdftk_path
      ENV.fetch("PDFTK_PATH") do
        %w[/usr/bin/pdftk /usr/local/bin/pdftk /usr/bin/pdftk-java].find do |path|
          File.exist?(path)
        end || "pdftk"
      end
    end

    def detect_field_type(field)
      type = field.type&.to_s&.downcase

      case type
      when "button"
        field.options&.any? ? "radio" : "checkbox"
      when "choice"
        "select"
      when "text"
        detect_text_subtype(field.name)
      else
        "text"
      end
    end

    def hexapdf_field_type(field)
      case field.field_type
      when :Btn
        field.check_box? ? "checkbox" : "radio"
      when :Ch
        "select"
      when :Tx
        detect_text_subtype(field.full_field_name)
      else
        "text"
      end
    end

    def detect_text_subtype(field_name)
      name = field_name.to_s.downcase

      case name
      when /date/ then "date"
      when /phone|tel/ then "tel"
      when /email/ then "email"
      when /amount|currency|\$|money/ then "currency"
      when /signature|sig/ then "signature"
      when /address/ then "address"
      else "text"
      end
    end
  end
end
