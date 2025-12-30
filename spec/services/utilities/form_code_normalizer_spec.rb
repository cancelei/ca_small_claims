# frozen_string_literal: true

require "rails_helper"

RSpec.describe Utilities::FormCodeNormalizer do
  describe ".normalize" do
    context "with lowercase input without hyphen" do
      it "normalizes sc100 to SC-100" do
        expect(described_class.normalize("sc100")).to eq("SC-100")
      end

      it "normalizes fl300a to FL-300A" do
        expect(described_class.normalize("fl300a")).to eq("FL-300A")
      end

      it "normalizes dv109 to DV-109" do
        expect(described_class.normalize("dv109")).to eq("DV-109")
      end
    end

    context "with uppercase input without hyphen" do
      it "normalizes SC100 to SC-100" do
        expect(described_class.normalize("SC100")).to eq("SC-100")
      end

      it "normalizes FL300A to FL-300A" do
        expect(described_class.normalize("FL300A")).to eq("FL-300A")
      end
    end

    context "with hyphenated input" do
      it "preserves and upcases SC-100" do
        expect(described_class.normalize("SC-100")).to eq("SC-100")
      end

      it "preserves and upcases sc-100" do
        expect(described_class.normalize("sc-100")).to eq("SC-100")
      end

      it "preserves FL-300A format" do
        expect(described_class.normalize("fl-300a")).to eq("FL-300A")
      end
    end

    context "with multi-letter prefixes" do
      it "normalizes pos010 to POS-010" do
        expect(described_class.normalize("pos010")).to eq("POS-010")
      end

      it "normalizes subp001 to SUBP-001" do
        expect(described_class.normalize("subp001")).to eq("SUBP-001")
      end

      it "normalizes disc005 to DISC-005" do
        expect(described_class.normalize("disc005")).to eq("DISC-005")
      end
    end

    context "with edge cases" do
      it "returns empty string for nil" do
        expect(described_class.normalize(nil)).to eq("")
      end

      it "returns empty string for blank string" do
        expect(described_class.normalize("")).to eq("")
      end

      it "handles whitespace" do
        expect(described_class.normalize("  sc100  ")).to eq("SC-100")
      end

      it "handles non-matching patterns gracefully" do
        expect(described_class.normalize("UNKNOWN")).to eq("UNKNOWN")
      end
    end
  end

  describe ".from_filename" do
    it "extracts and normalizes from simple filename" do
      expect(described_class.from_filename("sc100.pdf")).to eq("SC-100")
    end

    it "extracts and normalizes from path with filename" do
      expect(described_class.from_filename("/path/to/fl300a.pdf")).to eq("FL-300A")
    end

    it "handles filenames without extension" do
      expect(described_class.from_filename("dv109")).to eq("DV-109")
    end

    it "returns empty string for nil" do
      expect(described_class.from_filename(nil)).to eq("")
    end

    it "returns empty string for blank" do
      expect(described_class.from_filename("")).to eq("")
    end
  end

  describe ".to_filename" do
    it "converts SC-100 to sc100" do
      expect(described_class.to_filename("SC-100")).to eq("sc100")
    end

    it "converts fl300a to fl300a" do
      expect(described_class.to_filename("fl300a")).to eq("fl300a")
    end

    it "converts FL-300A to fl300a" do
      expect(described_class.to_filename("FL-300A")).to eq("fl300a")
    end
  end

  describe ".extract_prefix" do
    it "extracts SC from SC-100" do
      expect(described_class.extract_prefix("SC-100")).to eq("SC")
    end

    it "extracts FL from fl300a" do
      expect(described_class.extract_prefix("fl300a")).to eq("FL")
    end

    it "extracts SUBP from subp001" do
      expect(described_class.extract_prefix("subp001")).to eq("SUBP")
    end

    it "returns nil for nil input" do
      expect(described_class.extract_prefix(nil)).to be_nil
    end

    it "returns nil for blank input" do
      expect(described_class.extract_prefix("")).to be_nil
    end
  end

  describe ".extract_number" do
    it "extracts 100 from SC-100" do
      expect(described_class.extract_number("SC-100")).to eq(100)
    end

    it "extracts 300 from fl300a" do
      expect(described_class.extract_number("fl300a")).to eq(300)
    end

    it "extracts 1 from subp001" do
      expect(described_class.extract_number("subp001")).to eq(1)
    end

    it "returns 0 for non-matching input" do
      expect(described_class.extract_number("ABC")).to eq(0)
    end
  end

  describe "instance methods" do
    subject(:normalizer) { described_class.new }

    it "delegates normalize to class method" do
      expect(normalizer.normalize("sc100")).to eq("SC-100")
    end

    it "delegates from_filename to class method" do
      expect(normalizer.from_filename("sc100.pdf")).to eq("SC-100")
    end

    it "delegates to_filename to class method" do
      expect(normalizer.to_filename("SC-100")).to eq("sc100")
    end

    it "delegates extract_prefix to class method" do
      expect(normalizer.extract_prefix("SC-100")).to eq("SC")
    end

    it "delegates extract_number to class method" do
      expect(normalizer.extract_number("SC-100")).to eq(100)
    end
  end
end
