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

1. **Store templates** in `lib/pdf_templates/` (local) or S3 (production)
2. **Use service objects** for PDF operations
3. **Validate form data** before filling
4. **Handle encoding** issues (UTF-8)
5. **Clean up temp files** after processing
6. **Test with real PDFs** in specs

---

## S3 Template Storage

### Overview

PDF templates can be stored in IDRIVE S3 for both development and production environments. Templates are downloaded and cached locally for 24 hours to optimize performance and support pdftk/HexaPDF which require filesystem access.

### Configuration

Enable S3 storage via environment variables:

```bash
# .env
IDRIVE_ENDPOINT=3.us-west-2.idrivee2.com
IDRIVE_REGION_CODE=us-west-2
IDRIVE_ACCESS_KEY_ID=your_access_key
IDRIVE_SECRET_ASSET_KEY=your_secret_key
S3_BUCKET_NAME=casmallclaims
USE_S3_STORAGE=true  # Set to "true" to enable S3
```

The S3 service is configured in `config/initializers/s3.rb` and uses environment-specific prefixes:
- Development: `development/templates/`
- Production: `production/templates/`
- Staging: `staging/templates/`

### Upload Templates

Upload all PDF templates to S3:

```bash
# Upload all templates from lib/pdf_templates/
bin/rails s3:upload_templates

# Verify all templates were uploaded
bin/rails s3:verify_templates

# Test single download
bin/rails s3:download_template[sc100.pdf]
```

### Caching Behavior

Templates are cached locally in `tmp/cached_templates/` with a 24-hour TTL:

1. **First request**: Downloads from S3, caches locally
2. **Subsequent requests**: Uses cache if less than 24 hours old
3. **Stale cache**: Re-downloads from S3 automatically

Clear the cache manually:

```bash
bin/rails s3:clear_cache
```

### Service Usage

The `S3::TemplateService` handles all S3 operations:

```ruby
# Download a template (with automatic caching)
service = S3::TemplateService.new
path = service.download_template("sc100.pdf")
# => #<Pathname:/path/to/tmp/cached_templates/sc100.pdf>

# Upload a template
service.upload_template("/path/to/local.pdf", "sc100.pdf")

# Check if template exists
service.template_exists?("sc100.pdf")  # => true/false

# Get S3 URL
service.template_url("sc100.pdf")
# => "https://casmallclaims.3.us-west-2.idrivee2.com/development/templates/sc100.pdf"
```

### FormDefinition Integration

The `FormDefinition#pdf_path` method automatically handles S3 vs local storage:

```ruby
# When USE_S3_STORAGE=false (local)
form.pdf_path
# => #<Pathname:/path/to/lib/pdf_templates/sc100.pdf>

# When USE_S3_STORAGE=true (S3)
form.pdf_path
# => #<Pathname:/path/to/tmp/cached_templates/sc100.pdf> (downloaded from S3)
```

### Rollback Strategy

To revert to local storage:

```bash
# Set environment variable
USE_S3_STORAGE=false

# Restart application
bin/rails restart
```

The application will immediately fall back to reading from `lib/pdf_templates/` directory.

### Monitoring

Check S3 configuration:

```bash
bin/rails s3:show_config
```

Output:
```
S3 Configuration:
  Endpoint: https://3.us-west-2.idrivee2.com
  Region: us-west-2
  Bucket: casmallclaims
  Prefix: development/templates
  Access Key: GqhxaxiXZs...
  USE_S3_STORAGE: true
```
