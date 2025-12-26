# frozen_string_literal: true

module Forms
  class SchemaLoader
    SCHEMA_PATH = Rails.root.join("config", "form_schemas")

    class << self
      def load(form_code)
        # Search recursively for the schema file
        file_path = find_schema_file(form_code)
        raise "Schema not found: #{form_code}" unless file_path

        YAML.safe_load(
          File.read(file_path),
          permitted_classes: [Symbol, Date],
          symbolize_names: true
        )
      end

      def load_all
        schema_files.each_with_object({}) do |file, hash|
          form_code = File.basename(file, ".yml").upcase
          hash[form_code] = load(form_code)
        rescue StandardError => e
          Rails.logger.warn "Failed to load schema #{file}: #{e.message}"
        end
      end

      def exists?(form_code)
        find_schema_file(form_code).present?
      end

      def schema_files
        Dir.glob(SCHEMA_PATH.join("**", "*.yml"))
           .reject { |f| f.include?("_shared/") }
      end

      private

      def find_schema_file(form_code)
        # Try flat path first for backward compatibility
        flat_path = SCHEMA_PATH.join("#{form_code.downcase}.yml")
        return flat_path if File.exist?(flat_path)

        # Search recursively
        pattern = SCHEMA_PATH.join("**", "#{form_code.downcase}.yml")
        Dir.glob(pattern).reject { |f| f.include?("_shared/") }.first
      end

      public

      def sync_to_database!
        load_all.each do |code, schema|
          sync_form(code, schema)
        end
      end

      def sync_form(code, schema)
        form_data = schema[:form] || {}

        form = FormDefinition.find_or_initialize_by(code: code)
        form.update!(
          title: form_data[:title] || code,
          description: form_data[:description],
          category: form_data[:category],
          pdf_filename: form_data[:pdf_filename] || "#{code.downcase}.pdf",
          page_count: form_data[:page_count],
          metadata: form_data[:metadata] || {}
        )

        sync_fields!(form, schema)
        form
      end

      private

      def sync_fields!(form, schema)
        existing_field_ids = []
        position = 0

        (schema[:sections] || []).each do |section|
          (section[:fields] || []).each do |field_data|
            position += 1
            field = sync_field(form, section, field_data, position)
            existing_field_ids << field.id
          end
        end

        # Remove fields no longer in schema
        form.field_definitions.where.not(id: existing_field_ids).destroy_all
      end

      def sync_field(form, section, field_data, position)
        field = form.field_definitions.find_or_initialize_by(
          name: field_data[:name]
        )

        field.update!(
          pdf_field_name: field_data[:pdf_field_name] || field_data[:name],
          field_type: field_data[:type] || "text",
          label: field_data[:label],
          help_text: field_data[:help_text],
          placeholder: field_data[:placeholder],
          required: field_data[:required] || false,
          validation_pattern: field_data[:validation],
          max_length: field_data[:max_length],
          min_length: field_data[:min_length],
          section: section[:name],
          position: position,
          page_number: section[:page] || 1,
          width: field_data[:width] || "full",
          conditions: field_data[:conditions] || {},
          repeating_group: field_data[:repeating_group],
          max_repetitions: field_data[:max_repetitions],
          options: field_data[:options] || [],
          shared_field_key: field_data[:shared_key]
        )

        field
      end
    end
  end
end
