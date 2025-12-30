# Form Schema Guide

**Last Updated**: December 28, 2025
**Document Type**: Guide
**Audience**: Backend developers

---

## Overview

Form schemas define the structure, fields, and behavior of California court forms. Each form has a YAML schema that describes its fields, validation rules, and how data maps to PDF form fields.

| Component | Purpose |
|-----------|---------|
| YAML Schema | Defines form structure and field definitions |
| FormDefinition | Database model storing form metadata |
| FieldDefinition | Database model for individual fields |
| SchemaGenerator | Auto-generates schemas from PDF fields |
| SchemaValidator | Validates schema structure and content |

---

## Schema File Structure

Schemas are stored in `config/form_schemas/{category}/{subcategory}/{form_code}.yml`

```
config/form_schemas/
  _shared/
    field_key_registry.yml    # Shared field key definitions
  small_claims/
    plaintiff/
      sc100.yml
      sc105.yml
    defendant/
      sc120.yml
    judgment/
      sc108.yml
  family_law/
    dissolution/
      fl100.yml
  restraining_orders/
    domestic_violence/
      dv100.yml
```

---

## YAML Schema Format

### Complete Example

```yaml
# Form code and metadata
form:
  code: SC-100
  title: "Plaintiff's Claim and ORDER to Go to Small Claims Court"
  description: "Use this form to start a small claims case."
  category: plaintiff
  pdf_filename: sc100.pdf
  fillable: true
  instructions: |
    This form is used to file a small claims case. You must:
    1. Fill out this form completely
    2. File with the court clerk
    3. Have each defendant served

# Field sections
sections:
  court_info:
    title: "Court Information"
    description: "Enter the court where you are filing"
    fields:
      - name: court_name
        pdf_field_name: "CourtName"
        type: text
        label: "Court Name"
        placeholder: "Superior Court of California, County of..."
        required: true
        shared_key: "court:name"
        width: full
        help_text: "Enter the full name of the court"

  plaintiff_info:
    title: "Plaintiff Information"
    repeatable: true          # For multiple plaintiffs
    max_items: 4
    fields:
      - name: plaintiff_name
        pdf_field_name: "PlaintiffName"
        type: text
        label: "Your Full Legal Name"
        required: true
        shared_key: "plaintiff:name"
        width: full
```

---

## Field Properties

### Required Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | string | Database field name (snake_case) |
| `type` | string | Field type (see Field Types) |
| `label` | string | User-facing label |

### Optional Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `pdf_field_name` | string | `name` | Actual PDF form field name |
| `required` | boolean | `false` | Whether field is mandatory |
| `placeholder` | string | - | Placeholder text |
| `help_text` | string | - | Help text shown below field |
| `width` | string | `full` | Layout width (full, half, third, quarter) |
| `default` | any | - | Default value |
| `pattern` | string | - | Regex validation pattern |
| `shared_key` | string | - | Namespaced shared key for data sharing |
| `options` | array | - | Options for select/radio/checkbox_group |
| `conditions` | object | - | Conditional display rules |

---

## Field Types

| Type | Description | Example |
|------|-------------|---------|
| `text` | Single-line text input | Name, case number |
| `textarea` | Multi-line text | Descriptions, addresses |
| `tel` | Phone number | (555) 555-5555 |
| `email` | Email address | user@example.com |
| `date` | Date picker | 2025-01-15 |
| `currency` | Money amount | $1,234.56 |
| `number` | Numeric value | Age, count |
| `checkbox` | Single checkbox | Agreement |
| `checkbox_group` | Multiple checkboxes | Select all that apply |
| `radio` | Radio buttons | Single choice from options |
| `select` | Dropdown | State selection |
| `signature` | Signature field | Electronic signature |
| `address` | Address block | Full address with components |
| `hidden` | Hidden value | Pre-filled data |
| `readonly` | Read-only display | Court-filled values |

---

## Shared Field Keys

Shared keys enable data sharing across forms. Use namespaced keys:

```yaml
# Format: category:field_name
shared_key: "plaintiff:name"
shared_key: "court:address"
shared_key: "case:number"
```

### Available Namespaces

See `config/form_schemas/_shared/field_key_registry.yml` for complete list.

| Namespace | Usage |
|-----------|-------|
| `court:*` | Court information (name, address, branch) |
| `case:*` | Case information (number, type) |
| `plaintiff:*` | Plaintiff contact info |
| `defendant:*` | Defendant contact info |
| `petitioner:*` | Petitioner (Family Law) |
| `respondent:*` | Respondent (Family Law) |
| `protected_person:*` | Protected person (Restraining Orders) |
| `restrained_person:*` | Restrained person |
| `attorney:*` | Attorney information |
| `filing:*` | Filing details |
| `hearing:*` | Hearing details |

---

## Conditional Fields

Show/hide fields based on other field values:

```yaml
- name: demand_made
  type: checkbox
  label: "I asked the defendant to pay before filing"

- name: demand_date
  type: date
  label: "Date You Asked for Payment"
  conditions:
    show_when:
      field: demand_made
      value: true
```

---

## Repeatable Sections

For forms with multiple defendants, children, etc.:

```yaml
sections:
  defendant_info:
    title: "Defendant Information"
    repeatable: true
    max_items: 4
    fields:
      - name: defendant_name
        type: text
        label: "Defendant's Name"
```

---

## Generating Schemas

### Auto-Generate from PDF

```bash
# Single form
bin/rails schemas:generate[SC-100]

# All forms in a category
bin/rails schemas:generate_category[SC]

# With force regeneration
FORCE=true bin/rails schemas:generate_category[FL]
```

### Analyze PDFs

```bash
# View fillability report
bin/rails schemas:analyze[DV]
```

### Validate Schemas

```bash
# Validate all schemas
bin/rails forms:validate

# Sync to database
bin/rails forms:sync
```

---

## Progress Tracking

```bash
# Overall progress
bin/rails schemas:progress

# Category progress
bin/rails schemas:progress_category[SC]

# Missing schemas
bin/rails schemas:missing

# Missing HTML templates (non-fillable)
bin/rails schemas:missing_html
```

---

## Manual Review Queue

For forms that can't be auto-processed:

```bash
# Add to queue
bin/rails schemas:add_manual_review[FL-100,'Complex XFA form']

# View queue
bin/rails schemas:manual_review

# Resolve
bin/rails schemas:resolve_manual_review[FL-100]
```

---

## Best Practices

### Field Naming

```yaml
# CORRECT: snake_case, descriptive
name: plaintiff_street_address

# WRONG: camelCase, abbreviated
name: pltfStrAddr
```

### PDF Field Mapping

```yaml
# CORRECT: Preserve original PDF field name
name: plaintiff_name
pdf_field_name: "FL-100[0].Page1[0].Caption[0].Petitioner.Name[0]"

# WRONG: Assume simple mapping
name: "FL-100[0].Page1[0].Caption[0].Petitioner.Name[0]"
```

### Shared Keys

```yaml
# CORRECT: Namespaced
shared_key: "plaintiff:name"

# WRONG: Unnamespaced (collision risk)
shared_key: "plaintiff_name"
```

### Width Usage

```yaml
# Full width for long fields
- name: description
  width: full

# Half for paired fields
- name: city
  width: third
- name: state
  width: third
- name: zip
  width: third
```

---

## Related Documentation

- [PDF Processing Guide](pdf-processing.md) - PDF generation and filling
- [Form Anti-Patterns](form-anti-patterns.md) - Common mistakes to avoid
- [Testing Guide](../testing/testing-guide.md) - Testing form schemas
