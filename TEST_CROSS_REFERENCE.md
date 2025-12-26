# CA Small Claims Test Cross-Reference Guide

This document provides quick reference mappings between our test specifications and implemented tests, enabling developers to quickly find the correct patterns and examples for their testing needs.

## Test Specification Structure

### Primary Documentation
- **Main Spec**: `docs/guides/testing/testing-guide.md` - Overview and structure
- **Ruby Testing**: `docs/guides/testing/ruby_testing/README.md` - Model, service, form patterns
- **Turbo Testing**: `docs/guides/testing/turbo_testing/README.md` - Hotwire/Turbo patterns
- **Stimulus Testing**: `docs/guides/testing/stimulus_testing/README.md` - JavaScript controller patterns

## Quick Reference by Test Type

### Model Testing Patterns
**Spec Location**: `docs/guides/testing/ruby_testing/README.md`

| Pattern | Implementation Examples |
|---------|-------------------------|
| **Association Testing** | `spec/models/user_spec.rb`<br>`spec/models/submission_spec.rb`<br>`spec/models/form_definition_spec.rb` |
| **Validation Testing** | `spec/models/user_spec.rb`<br>`spec/models/workflow_spec.rb`<br>`spec/models/workflow_step_spec.rb` |
| **Business Logic Testing** | `spec/models/submission_spec.rb`<br>`spec/models/session_submission_spec.rb` |
| **Scope Testing** | `spec/models/submission_spec.rb`<br>`spec/models/category_spec.rb` |
| **Complex Method Testing** | `spec/models/workflow_spec.rb`<br>`spec/models/form_definition_spec.rb` |

### Service Object Testing Patterns
**Spec Location**: `docs/guides/testing/ruby_testing/README.md`

| Pattern | Implementation Examples |
|---------|-------------------------|
| **Form Services** | `spec/services/forms/*_spec.rb` |
| **PDF Generation** | `spec/services/pdf/*_spec.rb` |
| **Session Services** | `spec/services/sessions/*_spec.rb` |
| **Workflow Services** | `spec/services/workflows/*_spec.rb` |

### Turbo Testing Patterns
**Spec Location**: `docs/guides/testing/turbo_testing/README.md`

| Pattern | Implementation Examples |
|---------|-------------------------|
| **Turbo Frame Testing** | `spec/system/form_wizard_spec.rb`<br>`spec/system/submission_workflow_spec.rb` |
| **Turbo Stream Testing** | `spec/system/form_wizard_spec.rb`<br>`spec/system/complete_user_journey_spec.rb` |
| **Lazy Loading Testing** | `spec/system/turbo_frames_spec.rb` |
| **Form Integration** | `spec/system/form_wizard_spec.rb` |
| **Real-time Updates** | `spec/system/complete_user_journey_spec.rb` |
| **Error Handling** | `spec/system/form_wizard_spec.rb` |

### Stimulus Testing Patterns
**Spec Location**: `docs/guides/testing/stimulus_testing/README.md`

| Pattern | Implementation Examples |
|---------|-------------------------|
| **Controller Setup** | `spec/system/stimulus_controllers_spec.rb` |
| **Unit Testing Controllers** | `spec/javascript/*_controller_spec.js` |
| **Integration with Rails** | `spec/system/complete_user_journey_spec.rb` |
| **Form Wizard Events** | `spec/system/form_wizard_spec.rb` |

## Quick Search by Feature

### Authentication & Authorization
- **User Model**: `spec/models/user_spec.rb`
- **Request Authentication**: `spec/requests/*_spec.rb` -> Helper: `spec/support/devise.rb`
- **System Authentication**: `spec/system/*_spec.rb` -> Pattern: Sign-in helpers

### Form Management
- **FormDefinition Model**: `spec/models/form_definition_spec.rb`
- **FieldDefinition Model**: `spec/models/field_definition_spec.rb`
- **Form Services**: `spec/services/forms/*_spec.rb`
- **Form Wizard UI**: `spec/system/form_wizard_spec.rb`

### Submission System
- **Submission Model**: `spec/models/submission_spec.rb`
- **SessionSubmission Model**: `spec/models/session_submission_spec.rb`
- **Submission Workflows**: `spec/system/submission_workflow_spec.rb`

### Workflow System
- **Workflow Model**: `spec/models/workflow_spec.rb`
- **WorkflowStep Model**: `spec/models/workflow_step_spec.rb`
- **Workflow Services**: `spec/services/workflows/*_spec.rb`
- **Workflow UI**: `spec/system/workflow_spec.rb`

### PDF Generation
- **PDF Services**: `spec/services/pdf/*_spec.rb`
- **PDF Integration**: `spec/system/pdf_generation_spec.rb`

### Categories
- **Category Model**: `spec/models/category_spec.rb`
- **Category Navigation**: `spec/system/category_navigation_spec.rb`

## Development Workflow Quick Reference

### Adding New Model Tests
1. **Reference Pattern**: `docs/guides/testing/ruby_testing/README.md`
2. **Copy Structure**: Use `spec/models/user_spec.rb` as template
3. **Key Sections**: Associations -> Validations -> Business Logic
4. **Factory Integration**: Use FactoryBot patterns from `spec/factories/`

### Adding New System Tests
1. **Reference Pattern**: `docs/guides/testing/turbo_testing/README.md`
2. **Copy Structure**: Use existing system specs as template
3. **Turbo Patterns**: Frames -> Streams -> Forms
4. **Stimulus Integration**: `docs/guides/testing/stimulus_testing/README.md`

### Adding New Service Tests
1. **Reference Pattern**: `docs/guides/testing/ruby_testing/README.md`
2. **Copy Structure**: Use existing service specs as template
3. **Key Sections**: Initialization -> Logic -> Error Handling

## Test Helper Cross-Reference

### Authentication Helpers
- **File**: `spec/support/devise.rb`
- **Usage**: `sign_in user`, Devise test helpers
- **Reference**: Request specs and system tests

### Factory Helpers
- **File**: `spec/support/factory_bot.rb`
- **Usage**: `create(:user)`, `build(:submission)`
- **Reference**: All test types

### View Component Helpers
- **File**: `spec/support/view_component_helpers.rb`
- **Usage**: Component rendering in isolation
- **Reference**: ViewComponent tests

### VCR/WebMock Helpers
- **Files**: `spec/support/vcr.rb`, `spec/support/webmock.rb`
- **Usage**: External API mocking
- **Reference**: Service tests with external calls

### Timecop Helpers
- **File**: `spec/support/timecop.rb`
- **Usage**: Time-based testing
- **Reference**: Deadline and scheduling tests

## Running Tests

```bash
# Full test suite
bundle exec rspec

# Model tests only
bundle exec rspec spec/models/

# System tests with JS
bundle exec rspec spec/system/

# Specific test file
bundle exec rspec spec/models/user_spec.rb

# With coverage
COVERAGE=true bundle exec rspec

# JavaScript tests
npm run test
```

## Common Patterns Quick Access

### Model Validation Pattern
```ruby
# Reference: ruby_testing/README.md
describe "validations" do
  subject { create(:model_name) }

  it { should validate_presence_of(:field) }
  it { should validate_uniqueness_of(:field) }
  # ... more validations
end
```

### Turbo Frame Pattern
```ruby
# Reference: turbo_testing/README.md
expect(page).to have_css("turbo-frame#frame_id")
within("turbo-frame#frame_id") do
  expect(page).to have_content("Expected content")
end
```

### Stimulus Controller Pattern
```ruby
# Reference: stimulus_testing/README.md
expect(page).to have_css("[data-controller='controller-name']")
find("[data-action='click->controller-name#method']").click
expect(page).to have_css("[data-controller-name-target='result']")
```

### Service Testing Pattern
```ruby
# Reference: ruby_testing/README.md
describe ServiceName do
  let(:service) { described_class.new(params) }

  describe "#method_name" do
    it "performs expected operation" do
      result = service.method_name
      expect(result).to be_success
    end
  end
end
```

---

## How to Use This Reference

1. **Find Your Test Type**: Look up the pattern you need in the Quick Reference tables
2. **Check Documentation**: Reference the specific guides for detailed patterns
3. **Copy Implementation**: Use the provided implementation examples as templates
4. **Cross-Reference**: Use the feature-based search to find related tests
5. **Follow Patterns**: Maintain consistency with established patterns and helpers

This cross-reference ensures that all developers can quickly find the right testing patterns and maintain consistency across the CA Small Claims test suite.
