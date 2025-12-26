# Linting Guide

**Last Updated**: December 25, 2025
**Document Type**: Reference
**Audience**: All developers

---

## Overview

This project uses multiple linting tools to maintain code quality:

| Tool | Language | Config File |
|------|----------|-------------|
| RuboCop | Ruby | `.rubocop.yml` |
| ESLint | JavaScript | `eslint.config.js` |
| Stylelint | CSS/SCSS | `.stylelintrc.js` |
| ERB Lint | ERB templates | `.erb_lint.yml` |
| Brakeman | Security | N/A |

---

## Ruby Linting (RuboCop)

### Configuration

Uses Rails Omakase style guide via `rubocop-rails-omakase` gem.

### Commands

```bash
# Check for issues
bundle exec rubocop

# Auto-fix safe issues
bundle exec rubocop -a

# Auto-fix all issues (use with caution)
bundle exec rubocop -A

# Check specific file
bundle exec rubocop app/models/user.rb
```

### Disable Rules

```ruby
# rubocop:disable Style/FrozenStringLiteralComment
# your code
# rubocop:enable Style/FrozenStringLiteralComment
```

---

## JavaScript Linting (ESLint)

### Configuration

Uses `eslint-config-ackama` with Jest and Testing Library plugins.

### Commands

```bash
# Check for issues
npm run js-lint

# Auto-fix issues
npm run js-lint-fix
```

### Ignore Files

Add to `eslint.config.js` ignores array:

```javascript
{ ignores: ['path/to/ignore/*'] }
```

---

## CSS Linting (Stylelint)

### Configuration

Uses `stylelint-config-recommended-scss` with Tailwind-specific rules disabled.

### Commands

```bash
# Check for issues
npm run css-lint

# Auto-fix issues
npm run css-lint-fix
```

### Tailwind Integration

The config ignores Tailwind directives:

- `@tailwind`
- `@apply`
- `@layer`
- `@screen`

---

## ERB Linting

### Configuration

Configured in `.erb_lint.yml`.

### Commands

```bash
# Check for issues
bundle exec erb_lint .

# Auto-fix issues
bundle exec erb_lint --autocorrect .
```

---

## Security Scanning (Brakeman)

### Commands

```bash
# Run security scan
bundle exec brakeman

# Output to file
bundle exec brakeman -o brakeman_results.txt

# JSON output
bundle exec brakeman -f json -o brakeman.json
```

### Common Warnings

- SQL injection
- XSS vulnerabilities
- Mass assignment
- Unsafe redirects

---

## Pre-commit Hooks

Overcommit runs linting before each commit.

### Setup

```bash
bundle exec overcommit --install
bundle exec overcommit --sign
```

### Hooks Enabled

- `RuboCop` - Ruby linting
- `BundleCheck` - Gemfile consistency
- `YamlSyntax` - YAML validation
- `TrailingWhitespace` - Remove trailing spaces
- `RailsSchemaUpToDate` - Schema consistency

### Skip Hooks (use sparingly)

```bash
OVERCOMMIT_DISABLE=1 git commit -m "message"
```

---

## CI Integration

All linting tools run in CI pipeline:

```yaml
# .github/workflows/ci.yml
- name: RuboCop
  run: bundle exec rubocop

- name: ESLint
  run: npm run js-lint

- name: Brakeman
  run: bundle exec brakeman --no-exit-on-warn
```
