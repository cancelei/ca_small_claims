# frozen_string_literal: true

require "rails_helper"

RSpec.describe FormDataAccessor do
  # Create a test model class that includes the concern
  let(:test_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes
      include FormDataAccessor

      attribute :form_data, default: -> { {} }

      def save
        true
      end

      def new_record?
        true
      end

      def after_initialize
        # Trigger the callback manually for testing
        initialize_form_data if new_record?
      end
    end
  end

  let(:model) do
    instance = test_class.new
    instance.after_initialize
    instance
  end

  describe "#field_value" do
    it "returns the value for a string key" do
      model.form_data = { "name" => "John Doe" }
      expect(model.field_value("name")).to eq("John Doe")
    end

    it "returns the value when using symbol key" do
      model.form_data = { "name" => "John Doe" }
      expect(model.field_value(:name)).to eq("John Doe")
    end

    it "returns nil for non-existent field" do
      expect(model.field_value("missing")).to be_nil
    end
  end

  describe "#update_field" do
    it "adds a new field value" do
      model.update_field("name", "Jane Doe")
      expect(model.form_data["name"]).to eq("Jane Doe")
    end

    it "updates an existing field value" do
      model.form_data = { "name" => "John" }
      model.update_field("name", "Jane")
      expect(model.form_data["name"]).to eq("Jane")
    end

    it "accepts symbol keys" do
      model.update_field(:email, "test@example.com")
      expect(model.form_data["email"]).to eq("test@example.com")
    end

    it "calls after_form_data_update if defined" do
      model.define_singleton_method(:after_form_data_update) { @callback_called = true }
      model.instance_variable_set(:@callback_called, false)

      model.update_field("name", "Test")

      expect(model.instance_variable_get(:@callback_called)).to be true
    end
  end

  describe "#update_fields" do
    it "merges multiple field values" do
      model.form_data = { "existing" => "value" }

      model.update_fields({
        name: "Jane",
        email: "jane@example.com"
      })

      expect(model.form_data["existing"]).to eq("value")
      expect(model.form_data["name"]).to eq("Jane")
      expect(model.form_data["email"]).to eq("jane@example.com")
    end

    it "converts symbol keys to strings" do
      model.update_fields({ symbol_key: "value" })
      expect(model.form_data.keys).to include("symbol_key")
      expect(model.form_data.keys).not_to include(:symbol_key)
    end

    it "calls after_form_data_update if defined" do
      model.define_singleton_method(:after_form_data_update) { @callback_called = true }
      model.instance_variable_set(:@callback_called, false)

      model.update_fields({ name: "Test" })

      expect(model.instance_variable_get(:@callback_called)).to be true
    end
  end

  describe "#field_present?" do
    it "returns true for fields with values" do
      model.form_data = { "name" => "John" }
      expect(model.field_present?("name")).to be true
    end

    it "returns false for blank values" do
      model.form_data = { "name" => "" }
      expect(model.field_present?("name")).to be false
    end

    it "returns false for nil values" do
      model.form_data = { "name" => nil }
      expect(model.field_present?("name")).to be false
    end

    it "returns false for missing fields" do
      expect(model.field_present?("missing")).to be false
    end
  end

  describe "#filled_field_names" do
    it "returns array of field names with values" do
      model.form_data = {
        "filled1" => "value",
        "empty" => "",
        "filled2" => "another",
        "nil_field" => nil
      }

      expect(model.filled_field_names).to contain_exactly("filled1", "filled2")
    end

    it "returns empty array when no fields are filled" do
      model.form_data = { "empty" => "" }
      expect(model.filled_field_names).to be_empty
    end
  end

  describe "#filled_field_count" do
    it "returns the count of filled fields" do
      model.form_data = {
        "filled1" => "value",
        "empty" => "",
        "filled2" => "another"
      }

      expect(model.filled_field_count).to eq(2)
    end
  end

  describe "initialization" do
    it "initializes form_data as empty hash if nil" do
      instance = test_class.new
      instance.form_data = nil
      instance.after_initialize

      expect(instance.form_data).to eq({})
    end

    it "preserves existing form_data" do
      instance = test_class.new
      instance.form_data = { "existing" => "data" }
      instance.after_initialize

      expect(instance.form_data).to eq({ "existing" => "data" })
    end
  end
end
