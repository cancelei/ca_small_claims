# California Small Claims Court Forms

A free, open-source Ruby on Rails application that helps users fill out California Small Claims Court forms online and generate print-ready PDFs.

## Features

- **51 California Small Claims Court Forms**: All official Judicial Council forms for small claims cases
- **Guided Workflows**: Step-by-step wizards for common scenarios (filing a claim, responding to a claim, collecting a judgment)
- **Individual Form Access**: Fill out any form directly without going through a workflow
- **Smart Data Sharing**: Information entered once is automatically carried forward to related forms
- **PDF Generation**: Generate court-ready PDFs filled with your data
- **Auto-Save**: Your progress is automatically saved as you type
- **Anonymous Access**: Use without creating an account (72-hour session storage)
- **Optional Accounts**: Create an account to save your submissions permanently

## Tech Stack

- **Ruby on Rails 8.1** with Hotwire (Turbo + Stimulus)
- **Tailwind CSS** for styling
- **SQLite** (development) / **PostgreSQL** (production)
- **pdf-forms** gem with pdftk for PDF generation
- **Devise** for optional user authentication

## Prerequisites

- Ruby 3.3+
- Node.js 20+
- pdftk (for PDF generation)

### Installing pdftk

**Ubuntu/Debian:**
```bash
sudo apt-get install pdftk-java
```

**macOS:**
```bash
brew install pdftk-java
```

**Windows:**
Download from https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/

## Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/ca-small-claims.git
   cd ca-small-claims
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Set up the database:**
   ```bash
   bin/rails db:create db:migrate db:seed
   ```

4. **Link PDF templates:**
   ```bash
   ln -s /path/to/your/pdf/forms lib/pdf_templates
   ```

5. **Start the server:**
   ```bash
   bin/dev
   ```

6. **Visit http://localhost:3000**

## Project Structure

```
app/
├── controllers/
│   ├── forms_controller.rb      # Individual form access
│   ├── workflows_controller.rb  # Guided workflows
│   └── submissions_controller.rb # User submissions
├── models/
│   ├── form_definition.rb       # Form metadata
│   ├── field_definition.rb      # Field specifications
│   ├── workflow.rb              # Workflow definitions
│   ├── workflow_step.rb         # Steps within workflows
│   └── submission.rb            # User form data
├── services/
│   ├── pdf/
│   │   ├── field_extractor.rb   # Extract PDF field names
│   │   └── form_filler.rb       # Fill PDFs with data
│   ├── forms/
│   │   └── schema_loader.rb     # Load YAML schemas
│   ├── sessions/
│   │   └── storage_manager.rb   # Anonymous session storage
│   └── workflows/
│       └── engine.rb            # Workflow state machine
└── views/
    ├── forms/                   # Form views and field partials
    ├── workflows/               # Workflow wizard views
    └── submissions/             # User submissions views

config/
├── form_schemas/                # YAML form definitions
└── workflows/                   # YAML workflow definitions

lib/
└── pdf_templates/               # PDF form templates (symlink)
```

## Adding New Forms

1. **Create a YAML schema** in `config/form_schemas/`:

   ```yaml
   form:
     code: SC-XXX
     title: "Form Title"
     category: plaintiff
     pdf_filename: scxxx.pdf

   sections:
     section_name:
       title: "Section Title"
       fields:
         - name: field_name
           pdf_field_name: "PDFFieldName"
           type: text
           label: "Field Label"
           required: true
   ```

2. **Run the seed to load it:**
   ```bash
   bin/rails db:seed
   ```

## Available Form Types

- `text` - Single line text input
- `textarea` - Multi-line text input
- `date` - Date picker
- `currency` - Currency input with formatting
- `email` - Email with validation
- `tel` - Phone number input
- `select` - Dropdown selection
- `checkbox` - Single checkbox
- `signature` - Signature field

## Creating Workflows

1. **Create a YAML workflow** in `config/workflows/`:

   ```yaml
   workflow:
     name: "Workflow Name"
     slug: workflow_slug
     category: plaintiff
     description: "Description of the workflow"

   steps:
     - position: 1
       form_code: SC-100
       title: "Step Title"
       instructions: "Instructions for this step"
       required: true
       data_mappings:
         plaintiff_name: plaintiff_name
   ```

2. **Run the seed to load it:**
   ```bash
   bin/rails db:seed
   ```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PDFTK_PATH` | Path to pdftk binary | Auto-detected |
| `DATABASE_URL` | PostgreSQL URL (production) | - |
| `SECRET_KEY_BASE` | Rails secret key | - |

## Testing

```bash
bin/rails spec
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source and available under the [MIT License](LICENSE).

## Disclaimer

This application is provided as a convenience tool to help users fill out California Small Claims Court forms. It is not a substitute for legal advice. Please consult with a qualified attorney if you have questions about your legal rights or the small claims court process.

## Resources

- [California Courts Self-Help Center](https://selfhelp.courts.ca.gov/)
- [Small Claims Court Information](https://www.courts.ca.gov/selfhelp-smallclaims.htm)
- [Find Your Local Court](https://www.courts.ca.gov/find-my-court.htm)
