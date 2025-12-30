import { Controller } from "@hotwired/stimulus"
import { createDebouncedHandler, DEBOUNCE_DELAYS } from "../utilities/debounce"

// Handles live PDF preview with debounced refresh
export default class extends Controller {
  static targets = ["frame", "loading", "error", "autoRefreshToggle"]
  static values = {
    url: String,
    debounceDelay: { type: Number, default: DEBOUNCE_DELAYS.SLOW },
    autoRefresh: { type: Boolean, default: true }
  }

  connect() {
    this.isLoading = false
    this.debouncedRefresh = createDebouncedHandler(() => this.refresh())

    // Listen for form save events
    this.handleFormSaved = this.handleFormSaved.bind(this)
    document.addEventListener("form:saved", this.handleFormSaved)

    console.log("PDF Preview controller connected, URL:", this.urlValue)

    // Initial load
    this.loadPreview()
  }

  disconnect() {
    this.debouncedRefresh.cancel()
    document.removeEventListener("form:saved", this.handleFormSaved)
  }

  handleFormSaved(event) {
    console.log("PDF Preview received form:saved event", event.detail, "autoRefresh:", this.autoRefreshValue)
    if (!this.autoRefreshValue) return
    this.triggerDebouncedRefresh()
  }

  triggerDebouncedRefresh() {
    this.showLoading()
    this.debouncedRefresh.call(this.debounceDelayValue)
  }

  refresh() {
    this.loadPreview()
  }

  loadPreview() {
    if (!this.hasFrameTarget) return
    if (this.isLoading) return

    this.isLoading = true
    this.showLoading()
    this.hideError()

    // Add cache-busting timestamp
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("t", Date.now())

    this.frameTarget.src = url.toString()
  }

  handleLoad() {
    this.isLoading = false
    this.hideLoading()
    this.hideError()
  }

  handleError() {
    this.isLoading = false
    this.hideLoading()
    this.showError()
  }

  showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove("hidden")
    }
  }

  hideLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add("hidden")
    }
  }

  showError() {
    if (this.hasErrorTarget) {
      this.errorTarget.classList.remove("hidden")
    }
  }

  hideError() {
    if (this.hasErrorTarget) {
      this.errorTarget.classList.add("hidden")
    }
  }

  toggleAutoRefresh(event) {
    this.autoRefreshValue = event.target.checked
  }

  // Open preview in new tab
  openFullscreen() {
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("t", Date.now())
    window.open(url.toString(), "_blank")
  }
}
