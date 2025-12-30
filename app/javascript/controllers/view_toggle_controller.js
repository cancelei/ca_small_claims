import { Controller } from "@hotwired/stimulus"

// Handles toggling between wizard and traditional form views
// Persists preference in localStorage
export default class extends Controller {
  static targets = ["wizardContainer", "traditionalContainer", "toggle", "skipFilledLabel", "skipFilledCheckbox"]
  static values = {
    mode: { type: String, default: "wizard" },
    storageKey: { type: String, default: "formViewMode" }
  }

  connect() {
    // Restore preference from localStorage
    const savedMode = localStorage.getItem(this.storageKeyValue)
    if (savedMode && (savedMode === "wizard" || savedMode === "traditional")) {
      this.modeValue = savedMode
    }

    this.applyMode()
    this.updateToggle()
  }

  toggle(event) {
    // If triggered by a checkbox/toggle input
    if (event.target.type === "checkbox") {
      this.modeValue = event.target.checked ? "wizard" : "traditional"
    } else {
      // Toggle between modes
      this.modeValue = this.modeValue === "wizard" ? "traditional" : "wizard"
    }

    localStorage.setItem(this.storageKeyValue, this.modeValue)
    this.applyMode()
    this.updateToggle()
  }

  applyMode() {
    const isWizard = this.modeValue === "wizard"

    if (this.hasWizardContainerTarget) {
      this.wizardContainerTarget.classList.toggle("hidden", !isWizard)
    }

    if (this.hasTraditionalContainerTarget) {
      this.traditionalContainerTarget.classList.toggle("hidden", isWizard)
    }

    // Update skip-filled toggle state
    if (this.hasSkipFilledLabelTarget) {
      this.skipFilledLabelTarget.classList.toggle("opacity-50", !isWizard)
    }
    if (this.hasSkipFilledCheckboxTarget) {
      this.skipFilledCheckboxTarget.disabled = !isWizard
    }

    // Dispatch event for other controllers to react
    this.dispatch("modeChanged", { detail: { mode: this.modeValue } })
  }

  updateToggle() {
    if (this.hasToggleTarget) {
      this.toggleTarget.checked = this.modeValue === "wizard"
    }
  }

  // Programmatically set mode
  setWizardMode() {
    this.modeValue = "wizard"
    localStorage.setItem(this.storageKeyValue, this.modeValue)
    this.applyMode()
    this.updateToggle()
  }

  setTraditionalMode() {
    this.modeValue = "traditional"
    localStorage.setItem(this.storageKeyValue, this.modeValue)
    this.applyMode()
    this.updateToggle()
  }

  // Handle skip filled toggle - reload page with parameter
  toggleSkipFilled(event) {
    const skipFilled = event.target.checked
    const url = new URL(window.location)

    if (skipFilled) {
      url.searchParams.set("skip_filled", "true")
    } else {
      url.searchParams.delete("skip_filled")
    }

    // Use Turbo to navigate if available, otherwise standard navigation
    if (window.Turbo) {
      window.Turbo.visit(url.toString())
    } else {
      window.location.href = url.toString()
    }
  }
}
