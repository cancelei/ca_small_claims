# Turbo Guide

**Last Updated**: December 25, 2025
**Document Type**: Guide
**Audience**: Frontend developers

---

## Overview

This project uses Hotwire (Turbo + Stimulus) for frontend interactivity with minimal JavaScript.

### Core Concepts

- **Turbo Drive**: SPA-like navigation without page reloads
- **Turbo Frames**: Partial page updates
- **Turbo Streams**: Real-time DOM updates
- **Stimulus**: Lightweight JavaScript controllers

---

## Turbo Drive

Automatically intercepts link clicks and form submissions for faster navigation.

### Disable for Specific Links

```erb
<%= link_to "External", url, data: { turbo: false } %>
```

### Progress Bar

Turbo shows a progress bar during navigation. Customize in CSS:

```css
.turbo-progress-bar {
  background-color: theme('colors.primary');
}
```

---

## Turbo Frames

### Basic Frame

```erb
<%= turbo_frame_tag "user_profile" do %>
  <h2><%= @user.name %></h2>
  <%= link_to "Edit", edit_user_path(@user) %>
<% end %>
```

### Lazy Loading

```erb
<%= turbo_frame_tag "comments", src: comments_path, loading: :lazy do %>
  <p>Loading comments...</p>
<% end %>
```

### Target Parent Frame

```erb
<%= link_to "View All", users_path, data: { turbo_frame: "_top" } %>
```

---

## Turbo Streams

### Controller Response

```ruby
respond_to do |format|
  format.turbo_stream do
    render turbo_stream: turbo_stream.append("messages", @message)
  end
  format.html { redirect_to messages_path }
end
```

### Stream Actions

| Action | Description |
|--------|-------------|
| `append` | Add to end of container |
| `prepend` | Add to start of container |
| `replace` | Replace entire element |
| `update` | Replace inner HTML |
| `remove` | Remove element |
| `before` | Insert before element |
| `after` | Insert after element |

### Example Stream Template

```erb
<%# app/views/messages/create.turbo_stream.erb %>
<%= turbo_stream.append "messages" do %>
  <%= render @message %>
<% end %>

<%= turbo_stream.update "message_count", Message.count %>
```

---

## Stimulus Controllers

### Basic Controller

```javascript
// app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]
  static values = { open: Boolean }

  toggle() {
    this.openValue = !this.openValue
  }

  openValueChanged() {
    this.contentTarget.classList.toggle("hidden", !this.openValue)
  }
}
```

### Usage in Views

```erb
<div data-controller="toggle" data-toggle-open-value="false">
  <button data-action="toggle#toggle">Toggle</button>
  <div data-toggle-target="content" class="hidden">
    Content here
  </div>
</div>
```

---

## Form Patterns

### Form Submission with Stream

```erb
<%= form_with model: @message, data: { turbo_stream: true } do |f| %>
  <%= f.text_field :content %>
  <%= f.submit %>
<% end %>
```

### Disable Button During Submit

```erb
<%= f.submit "Save", data: { turbo_submits_with: "Saving..." } %>
```

---

## Best Practices

1. **Prefer Turbo Frames** over full page reloads
2. **Use Turbo Streams** for real-time updates
3. **Keep Stimulus controllers small** and focused
4. **Use data attributes** for configuration
5. **Test frame/stream behavior** in system specs
