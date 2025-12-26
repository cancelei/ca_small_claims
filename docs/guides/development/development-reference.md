# Development Reference

**Last Updated**: December 25, 2025
**Document Type**: Reference
**Audience**: All developers

---

## Quick Start

```bash
# Install dependencies
bundle install
npm install

# Setup database
bin/rails db:setup

# Start development server
bin/dev
```

---

## Daily Workflow Commands

### Development Server

```bash
# Start all services (Rails, Tailwind watch, etc.)
bin/dev

# Start Rails only
bin/rails server

# Start Rails console
bin/rails console
```

### Testing

```bash
# Run all RSpec tests
bundle exec rspec

# Run specific spec file
bundle exec rspec spec/models/user_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec

# Run JavaScript tests
npm test

# Run E2E tests
npm run test:e2e
```

### Linting

```bash
# Ruby linting
bundle exec rubocop

# Auto-fix Ruby issues
bundle exec rubocop -a

# JavaScript linting
npm run js-lint

# CSS linting
npm run css-lint

# ERB linting
bundle exec erb_lint .

# Security scanning
bundle exec brakeman
```

### Database

```bash
# Create migration
bin/rails generate migration AddFieldToTable field:type

# Run migrations
bin/rails db:migrate

# Rollback last migration
bin/rails db:rollback

# Reset database
bin/rails db:reset

# Seed database
bin/rails db:seed
```

---

## Code Quality Tools

### RuboCop

Ruby linting with Rails Omakase style guide.

```bash
bundle exec rubocop
bundle exec rubocop -a  # Auto-fix
```

### Brakeman

Security vulnerability scanner.

```bash
bundle exec brakeman
bundle exec brakeman -o brakeman_results.txt
```

### ESLint

JavaScript linting.

```bash
npm run js-lint
npm run js-lint-fix
```

### Stylelint

CSS linting with Tailwind support.

```bash
npm run css-lint
npm run css-lint-fix
```

### ERB Lint

ERB template linting.

```bash
bundle exec erb_lint .
bundle exec erb_lint --autocorrect .
```

---

## Git Workflow

### Commit Convention

```
type(scope): description

Types: feat, fix, docs, style, refactor, test, chore
```

### Pre-commit Hooks

Overcommit runs these checks before each commit:

- RuboCop
- Bundle check
- YAML syntax
- Trailing whitespace
- Schema up to date

---

## Environment Variables

Create `.env` from `example.env`:

```bash
cp example.env .env
```

Key variables:

- `DATABASE_URL` - Database connection
- `RAILS_ENV` - Environment (development/test/production)
- `SECRET_KEY_BASE` - Rails secret key
