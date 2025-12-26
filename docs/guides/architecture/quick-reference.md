# Architecture Quick Reference

**Last Updated**: December 25, 2025
**Document Type**: Reference
**Audience**: All developers

---

## Project Structure

```
app/
├── components/      # ViewComponents
├── controllers/     # Rails controllers
├── helpers/         # View helpers
├── javascript/      # Stimulus controllers
├── jobs/           # Background jobs (Solid Queue)
├── mailers/        # Email classes
├── models/         # ActiveRecord models
├── policies/       # Pundit authorization
├── services/       # Business logic
└── views/          # ERB templates

config/
├── initializers/   # App configuration
├── locales/        # I18n translations
└── routes.rb       # URL routing

db/
├── migrate/        # Database migrations
├── schema.rb       # Current schema
└── seeds.rb        # Seed data

docs/
└── guides/         # Documentation

lib/
├── pdf_templates/  # PDF form templates
└── tasks/          # Rake tasks

spec/
├── components/     # ViewComponent specs
├── factories/      # FactoryBot factories
├── models/         # Model specs
├── requests/       # Request specs
├── services/       # Service specs
├── support/        # Test helpers
└── system/         # System specs
```

---

## Key Patterns

### Service Objects

Business logic in `app/services/`:

```ruby
class ClaimCreator
  def initialize(user, params)
    @user = user
    @params = params
  end

  def call
    # Business logic here
  end
end
```

### ViewComponents

Reusable UI components in `app/components/`:

```ruby
class ButtonComponent < ViewComponent::Base
  def initialize(label:, variant: :primary)
    @label = label
    @variant = variant
  end
end
```

### Policies

Authorization in `app/policies/`:

```ruby
class ClaimPolicy < ApplicationPolicy
  def update?
    record.user == user
  end
end
```

---

## Technology Stack

| Layer | Technology |
|-------|------------|
| Framework | Rails 8.1 |
| Database | PostgreSQL |
| Cache | Solid Cache |
| Jobs | Solid Queue |
| WebSocket | Solid Cable |
| Frontend | Turbo + Stimulus |
| CSS | Tailwind + DaisyUI |
| Components | ViewComponent |
| Auth | Devise |
| Authorization | Pundit |
| PDF | pdf-forms, CombinePDF |
| Testing | RSpec, Capybara |

---

## Key Gems

### Core

- `rails` - Web framework
- `pg` - PostgreSQL adapter
- `puma` - Web server
- `devise` - Authentication
- `pundit` - Authorization

### Frontend

- `turbo-rails` - Turbo integration
- `stimulus-rails` - Stimulus integration
- `view_component` - Components
- `tailwindcss-rails` - CSS framework

### Background Processing

- `solid_queue` - Job queue
- `solid_cache` - Caching
- `solid_cable` - WebSockets

### PDF Processing

- `pdf-forms` - Form filling
- `combine_pdf` - PDF merging
- `hexapdf` - PDF parsing

### Testing

- `rspec-rails` - Testing framework
- `factory_bot_rails` - Test factories
- `capybara` - Browser testing
- `simplecov` - Code coverage

---

## Database

### Key Tables

- `users` - User accounts
- `claims` - Small claims cases
- `documents` - Uploaded files
- `form_submissions` - PDF submissions

### Conventions

- Use `references` for foreign keys
- Add indexes on foreign keys
- Use `strong_migrations` for safety
