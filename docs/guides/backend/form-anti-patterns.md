# Form Implementation Anti-Patterns

**Last Updated**: December 28, 2025
**Document Type**: Reference
**Audience**: Backend developers, AI agents

---

## Overview

This document captures common mistakes and anti-patterns discovered during form implementation. Following these guidelines prevents bugs, data corruption, and maintenance headaches.

---

## Schema Generation Anti-Patterns

### 1. Using Unsanitized PDF Field Names

```yaml
# WRONG: Raw PDF field name as field name
- name: "FL-100[0].Page1[0].Caption[0].Petitioner.Name[0]"
  type: text
  label: "Petitioner Name"
```

```yaml
# CORRECT: Sanitized name with PDF mapping
- name: petitioner_name
  pdf_field_name: "FL-100[0].Page1[0].Caption[0].Petitioner.Name[0]"
  type: text
  label: "Petitioner Name"
```

**Why**: Unsanitized names break database queries, form rendering, and are impossible to reference in code.

---

### 2. Duplicate Field Names Without Suffix

```yaml
# WRONG: Same name for repeating fields
sections:
  defendants:
    fields:
      - name: defendant_name   # First defendant
        type: text
      - name: defendant_name   # Collision!
        type: text
```

```yaml
# CORRECT: Position suffix for repeating fields
sections:
  defendants:
    fields:
      - name: defendant_name_1
        type: text
      - name: defendant_name_2
        type: text
```

**Why**: Duplicate names cause validation errors and data loss.

---

### 3. Unnamespaced Shared Keys

```yaml
# WRONG: Global shared key (collision risk)
- name: plaintiff_name
  shared_key: plaintiff_name
```

```yaml
# CORRECT: Namespaced shared key
- name: plaintiff_name
  shared_key: "plaintiff:name"
```

**Why**: Unnamespaced keys can collide with other forms. `plaintiff_name` vs `plaintiff:name` prevents ambiguity between Small Claims plaintiff and Family Law petitioner.

---

### 4. Wrong Category Mapping

```yaml
# WRONG: Using plaintiff/defendant for Family Law
form:
  code: FL-100
  category: plaintiff    # Wrong! FL uses petitioner/respondent
```

```yaml
# CORRECT: Category matches form type
form:
  code: FL-100
  category: family_law/dissolution
```

**Why**: Small Claims uses plaintiff/defendant; Family Law uses petitioner/respondent. Mixing causes confusion and shared key collisions.

---

## Field Type Anti-Patterns

### 5. Assuming All "Amount" Fields Are Currency

```yaml
# WRONG: Blindly classifying as currency
- name: number_of_amounts
  type: currency      # Not money!
```

```yaml
# CORRECT: Context-aware classification
- name: number_of_amounts
  type: number        # It's a count, not money
```

**Why**: Pattern matching can be wrong. Always verify field context.

---

### 6. Ignoring PDF-Reported Field Type

```yaml
# WRONG: Overriding checkbox type
# PDF reports: type=Button, options=[Yes,Off]
- name: agree_terms
  type: text          # Ignoring PDF type
```

```yaml
# CORRECT: Respect PDF type
- name: agree_terms
  type: checkbox
  pdf_field_name: "AgreeTerms"
```

**Why**: PDF field types are authoritative. Overriding them breaks form filling.

---

### 7. Missing Required Fields on Legal Forms

```yaml
# WRONG: Making signature optional
- name: petitioner_signature
  type: signature
  required: false     # Legal forms require signatures!
```

```yaml
# CORRECT: Signatures are required
- name: petitioner_signature
  type: signature
  required: true
  help_text: "By signing, you declare under penalty of perjury..."
```

**Why**: Court forms have legal requirements. Submitting without required fields wastes user time.

---

## Non-Fillable Form Anti-Patterns

### 8. Creating HTML Templates for Court-Completed Forms

```yaml
# WRONG: Creating HTML template for SC-130 (Judgment)
# This form is completed by the COURT, not the user
```

```yaml
# CORRECT: Use copy_original_pdf strategy
# Don't create HTML template - the court fills this form
form:
  code: SC-130
  fillable: false
  # No HTML template needed
```

**Why**: Some forms (Judgments, Orders) are completed by court staff. Creating user-facing HTML templates is wasted effort.

---

### 9. Trying to Extract Fields from Non-Fillable PDFs

```ruby
# WRONG: Expecting fields from informational PDF
extractor = Pdf::FieldExtractor.new("sc107.pdf")
fields = extractor.extract  # Returns []
# Then failing because no fields found
```

```ruby
# CORRECT: Check fillability first
if fields.empty?
  # This is a non-fillable form
  generate_non_fillable_schema(pdf_path)
end
```

**Why**: Many court forms are informational (INFO sheets) without fillable fields.

---

## Shared Key Anti-Patterns

### 10. Mixing Plaintiff/Petitioner Shared Keys

```yaml
# WRONG: Using both on same form
- name: plaintiff_name
  shared_key: "plaintiff:name"
- name: petitioner_name
  shared_key: "petitioner:name"
```

**Why**: A form is either Small Claims (plaintiff/defendant) or Family Law (petitioner/respondent), never both.

---

### 11. Not Using Shared Keys for Common Fields

```yaml
# WRONG: Court name without shared key
- name: court_name
  type: text
  # Missing shared_key!
```

```yaml
# CORRECT: Always share common fields
- name: court_name
  type: text
  shared_key: "court:name"
```

**Why**: Users shouldn't re-enter court name on every form.

---

## PDF Field Mapping Anti-Patterns

### 12. Ignoring Hierarchical Field Names

```yaml
# WRONG: Flat section structure
sections:
  general:
    fields:
      - name: caption_petitioner_name
      - name: caption_respondent_name
      - name: item1_checkbox
```

```yaml
# CORRECT: Use hierarchy from PDF field names
# PDF: DV-100[0].Caption[0].Petitioner.Name[0]
sections:
  caption:
    title: "Case Caption"
    fields:
      - name: petitioner_name
      - name: respondent_name
  item1:
    title: "Item 1"
    fields:
      - name: checkbox
```

**Why**: PDF field hierarchy reveals form structure. Use it for better UX.

---

### 13. Hardcoding Field Positions

```yaml
# WRONG: Relying on field order
- name: field_1
  position: 1
- name: field_2
  position: 2
```

**Why**: PDF fields may not be in visual order. Position should be inferred during sync, not hardcoded.

---

## Validation Anti-Patterns

### 14. Overly Strict Patterns

```yaml
# WRONG: Too strict ZIP validation
- name: zip
  pattern: "^\\d{5}$"  # Rejects ZIP+4
```

```yaml
# CORRECT: Accept common formats
- name: zip
  pattern: "^\\d{5}(-\\d{4})?$"
```

**Why**: Users enter ZIP+4 codes. Don't reject valid input.

---

### 15. Missing Help Text for Complex Fields

```yaml
# WRONG: No guidance for legal statement
- name: venue_reason
  type: select
  label: "Why are you filing here?"
```

```yaml
# CORRECT: Explain the legal requirement
- name: venue_reason
  type: select
  label: "Why are you filing in this court?"
  help_text: "You must file in the correct court location. Choose the reason that applies to your case."
```

**Why**: Users don't know legal venue requirements.

---

## Performance Anti-Patterns

### 16. Loading All Schemas at Once

```ruby
# WRONG: Load all 1500 schemas at startup
Forms::SchemaLoader.load_all  # Slow!
```

```ruby
# CORRECT: Lazy load on demand
def schema_for(form_code)
  @schemas[form_code] ||= Forms::SchemaLoader.load(form_code)
end
```

**Why**: Loading 1500 YAML files at startup kills performance.

---

### 17. Not Caching Field Extraction

```ruby
# WRONG: Extract fields every time
def generate_pdf(submission)
  extractor = Pdf::FieldExtractor.new(pdf_path)
  fields = extractor.extract  # Slow every time
end
```

```ruby
# CORRECT: Use cached field definitions
def generate_pdf(submission)
  fields = submission.form_definition.field_definitions
end
```

**Why**: PDF field extraction is slow. Use database-cached definitions.

---

## Lessons Learned Log

### December 2025: Small Claims Batch

**Issue**: SC-100 defendant fields appeared 4 times without position suffix
**Root Cause**: Repeatable section logic not detecting duplicates
**Solution**: Added position suffix in `Forms::SchemaGenerator#build_field_definition`
**Files Changed**: `app/services/forms/schema_generator.rb`

---

### December 2025: Family Law Forms

**Issue**: FL forms using XFA format couldn't be extracted by pdftk
**Root Cause**: XFA (XML Forms Architecture) not supported by pdftk
**Solution**: HexaPDF fallback already implemented in `Pdf::FieldExtractor`
**Files Changed**: None (fallback worked)

---

## Related Documentation

- [Form Schema Guide](form-schemas.md) - Schema format and usage
- [PDF Processing Guide](pdf-processing.md) - PDF generation
- [Testing Guide](../testing/testing-guide.md) - Testing strategies
