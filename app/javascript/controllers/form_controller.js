import { Controller } from "@hotwired/stimulus"

// Handles form auto-save functionality
export default class extends Controller {
  static targets = ["status", "form"]
  static values = {
    saveUrl: String,
    debounceDelay: { type: Number, default: 1000 }
  }

  connect() {
    this.pendingChanges = false
    this.saveTimeout = null
    console.log("Form controller connected")
  }

  disconnect() {
    if (this.saveTimeout) {
      clearTimeout(this.saveTimeout)
    }
  }

  fieldChanged(event) {
    this.pendingChanges = true
    this.updateStatus("saving")
    this.debouncedSave()
  }

  debouncedSave() {
    if (this.saveTimeout) {
      clearTimeout(this.saveTimeout)
    }

    this.saveTimeout = setTimeout(() => {
      this.save()
    }, this.debounceDelayValue)
  }

  async save() {
    if (!this.pendingChanges) return

    const form = this.hasFormTarget ? this.formTarget : this.element
    const formData = new FormData(form)

    try {
      const response = await fetch(this.saveUrlValue || form.action, {
        method: "PATCH",
        body: formData,
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']")?.content
        }
      })

      if (response.ok) {
        this.pendingChanges = false
        this.updateStatus("saved")
      } else {
        this.updateStatus("error")
        console.error("Save failed:", response.statusText)
      }
    } catch (error) {
      this.updateStatus("error")
      console.error("Save error:", error)
    }
  }

  updateStatus(status) {
    if (!this.hasStatusTarget) return

    const statusEl = this.statusTarget

    switch (status) {
      case "saving":
        statusEl.innerHTML = `
          <span class="text-gray-500">
            <svg class="inline w-4 h-4 mr-1 animate-spin" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            Saving...
          </span>
        `
        break
      case "saved":
        statusEl.innerHTML = `
          <span class="text-green-600">
            <svg class="inline w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            Saved just now
          </span>
        `
        break
      case "error":
        statusEl.innerHTML = `
          <span class="text-red-600">
            <svg class="inline w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            Save failed
          </span>
        `
        break
    }
  }

  // Warn user before leaving with unsaved changes
  beforeUnload(event) {
    if (this.pendingChanges) {
      event.preventDefault()
      event.returnValue = ""
    }
  }
}
