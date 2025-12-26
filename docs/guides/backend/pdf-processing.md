# PDF Processing Guide

**Last Updated**: December 25, 2025
**Document Type**: Guide
**Audience**: Backend developers

---

## Overview

This application handles California Small Claims Court PDF forms. We use several gems for PDF processing:

| Gem | Purpose |
|-----|---------|
| `pdf-forms` | Fill PDF forms using pdftk |
| `combine_pdf` | Merge and manipulate PDFs |
| `hexapdf` | Parse PDFs (including XFA forms) |
| `pdf-reader` | Read PDF content (testing) |

---

## Dependencies

Requires pdftk installed on the system:

```bash
# Ubuntu/Debian
sudo apt-get install pdftk

# macOS
brew install pdftk-java
```

---

## Filling PDF Forms

### Basic Form Filling

```ruby
require 'pdf_forms'

pdftk = PdfForms.new('/usr/bin/pdftk')

pdftk.fill_form(
  'path/to/template.pdf',
  'path/to/output.pdf',
  {
    'plaintiff_name' => 'John Doe',
    'defendant_name' => 'Jane Smith',
    'claim_amount' => '5000.00'
  }
)
```

### Service Object Pattern

```ruby
# app/services/pdf_form_filler.rb
class PdfFormFiller
  def initialize(template_path)
    @template_path = template_path
    @pdftk = PdfForms.new(pdftk_path)
  end

  def fill(output_path, data)
    @pdftk.fill_form(@template_path, output_path, data, flatten: true)
  end

  private

  def pdftk_path
    ENV.fetch('PDFTK_PATH', '/usr/bin/pdftk')
  end
end
```

---

## Merging PDFs

```ruby
require 'combine_pdf'

# Load PDFs
pdf1 = CombinePDF.load('form1.pdf')
pdf2 = CombinePDF.load('form2.pdf')

# Merge
combined = CombinePDF.new
combined << pdf1
combined << pdf2

# Save
combined.save('combined.pdf')
```

---

## Reading PDF Fields

```ruby
require 'pdf_forms'

pdftk = PdfForms.new('/usr/bin/pdftk')
fields = pdftk.get_field_names('template.pdf')

fields.each do |field|
  puts "Field: #{field}"
end
```

---

## Testing PDFs

```ruby
require 'pdf-reader'

RSpec.describe PdfFormFiller do
  it 'fills form correctly' do
    filler = PdfFormFiller.new('spec/fixtures/template.pdf')
    output_path = 'tmp/test_output.pdf'

    filler.fill(output_path, { 'name' => 'Test User' })

    reader = PDF::Reader.new(output_path)
    text = reader.pages.map(&:text).join

    expect(text).to include('Test User')
  end
end
```

---

## Error Handling

```ruby
class PdfFormFiller
  class PdfError < StandardError; end

  def fill(output_path, data)
    @pdftk.fill_form(@template_path, output_path, data, flatten: true)
  rescue PdfForms::PdftkError => e
    raise PdfError, "Failed to fill PDF: #{e.message}"
  end
end
```

---

## Best Practices

1. **Store templates** in `lib/pdf_templates/`
2. **Use service objects** for PDF operations
3. **Validate form data** before filling
4. **Handle encoding** issues (UTF-8)
5. **Clean up temp files** after processing
6. **Test with real PDFs** in specs
