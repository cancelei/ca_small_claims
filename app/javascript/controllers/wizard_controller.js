import { Controller } from "@hotwired/stimulus"

// Handles wizard-style single-question form navigation with 3D card flip animations
export default class extends Controller {
  static targets = ["card", "progress", "counter", "prevBtn", "nextBtn", "finishBtn", "skipToggle"]
  static values = {
    currentIndex: { type: Number, default: 0 },
    totalFields: Number,
    skipFilled: { type: Boolean, default: false },
    animationDuration: { type: Number, default: 500 }
  }

  connect() {
    this.updateVisibility()
    this.updateProgress()
    this.bindKeyboardNavigation()
    this.focusCurrentInput()
  }

  disconnect() {
    this.unbindKeyboardNavigation()
  }

  bindKeyboardNavigation() {
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.handleKeydown)
  }

  unbindKeyboardNavigation() {
    document.removeEventListener("keydown", this.handleKeydown)
  }

  handleKeydown(event) {
    // Don't navigate if user is typing in a textarea
    if (event.target.tagName === "TEXTAREA") return

    if (event.key === "Enter" && !event.shiftKey) {
      // Don't interfere with form submission on last field
      if (this.currentIndexValue >= this.totalFieldsValue - 1) return

      if (this.canAdvance()) {
        event.preventDefault()
        this.next()
      }
    } else if (event.key === "ArrowRight" && (event.metaKey || event.ctrlKey)) {
      if (this.canAdvance()) {
        event.preventDefault()
        this.next()
      }
    } else if (event.key === "ArrowLeft" && (event.metaKey || event.ctrlKey)) {
      if (this.currentIndexValue > 0) {
        event.preventDefault()
        this.previous()
      }
    }
  }

  next() {
    if (this.currentIndexValue >= this.totalFieldsValue - 1) return
    if (!this.canAdvance()) {
      this.showValidationMessage()
      return
    }

    this.flipCard("next")
  }

  previous() {
    if (this.currentIndexValue <= 0) return

    this.flipCard("prev")
  }

  goTo(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    if (index === this.currentIndexValue) return
    if (index < 0 || index >= this.totalFieldsValue) return

    const direction = index > this.currentIndexValue ? "next" : "prev"

    // For jumping multiple steps, we just animate once
    const currentCard = this.cardTargets[this.currentIndexValue]
    const targetCard = this.cardTargets[index]

    if (!currentCard || !targetCard) return

    // Apply exit animation to current card
    currentCard.classList.add("wizard-flip-exit", `wizard-flip-${direction}`)

    setTimeout(() => {
      currentCard.classList.add("hidden")
      currentCard.classList.remove("wizard-flip-exit", `wizard-flip-${direction}`, "wizard-card-active")

      this.currentIndexValue = index
      this.updateVisibility()
      this.updateProgress()

      // Apply enter animation to target card
      targetCard.classList.remove("hidden")
      targetCard.classList.add("wizard-card-active", "wizard-flip-enter", `wizard-flip-${direction}`)

      setTimeout(() => {
        targetCard.classList.remove("wizard-flip-enter", `wizard-flip-${direction}`)
        this.focusCurrentInput()
      }, this.animationDurationValue)
    }, this.animationDurationValue)
  }

  flipCard(direction) {
    const currentCard = this.cardTargets[this.currentIndexValue]
    const nextIndex = direction === "next"
      ? this.currentIndexValue + 1
      : this.currentIndexValue - 1
    const nextCard = this.cardTargets[nextIndex]

    if (!currentCard || !nextCard) return

    // Apply exit animation to current card
    currentCard.classList.add("wizard-flip-exit", `wizard-flip-${direction}`)

    setTimeout(() => {
      // Hide current card after animation
      currentCard.classList.add("hidden")
      currentCard.classList.remove("wizard-flip-exit", `wizard-flip-${direction}`, "wizard-card-active")

      // Update index
      this.currentIndexValue = nextIndex
      this.updateVisibility()
      this.updateProgress()

      // Show and animate new card
      nextCard.classList.remove("hidden")
      nextCard.classList.add("wizard-card-active", "wizard-flip-enter", `wizard-flip-${direction}`)

      setTimeout(() => {
        nextCard.classList.remove("wizard-flip-enter", `wizard-flip-${direction}`)
        this.focusCurrentInput()
      }, this.animationDurationValue)
    }, this.animationDurationValue)
  }

  updateVisibility() {
    this.cardTargets.forEach((card, index) => {
      const isActive = index === this.currentIndexValue
      card.classList.toggle("hidden", !isActive)
      card.classList.toggle("wizard-card-active", isActive)
    })

    // Update navigation buttons
    if (this.hasPrevBtnTarget) {
      this.prevBtnTarget.disabled = this.currentIndexValue === 0
      this.prevBtnTarget.classList.toggle("btn-disabled", this.currentIndexValue === 0)
    }

    if (this.hasNextBtnTarget) {
      const isLastField = this.currentIndexValue === this.totalFieldsValue - 1
      this.nextBtnTarget.classList.toggle("hidden", isLastField)
    }

    if (this.hasFinishBtnTarget) {
      const isLastField = this.currentIndexValue === this.totalFieldsValue - 1
      this.finishBtnTarget.classList.toggle("hidden", !isLastField)
    }
  }

  updateProgress() {
    const percent = this.totalFieldsValue > 0
      ? ((this.currentIndexValue + 1) / this.totalFieldsValue) * 100
      : 0

    if (this.hasProgressTarget) {
      this.progressTarget.style.width = `${percent}%`
    }

    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${this.currentIndexValue + 1} / ${this.totalFieldsValue}`
    }
  }

  focusCurrentInput() {
    const currentCard = this.cardTargets[this.currentIndexValue]
    if (!currentCard) return

    // Small delay to ensure DOM is ready
    setTimeout(() => {
      const input = currentCard.querySelector("input:not([type='hidden']), select, textarea")
      if (input && !input.disabled) {
        input.focus()
      }
    }, 100)
  }

  canAdvance() {
    const currentCard = this.cardTargets[this.currentIndexValue]
    if (!currentCard) return true

    const requiredInputs = currentCard.querySelectorAll("[required]")
    return Array.from(requiredInputs).every(input => {
      if (input.type === "checkbox") return input.checked
      if (input.type === "radio") {
        const name = input.name
        const radioGroup = currentCard.querySelectorAll(`[name="${name}"]`)
        return Array.from(radioGroup).some(r => r.checked)
      }
      return input.value.trim() !== ""
    })
  }

  showValidationMessage() {
    const currentCard = this.cardTargets[this.currentIndexValue]
    if (!currentCard) return

    const requiredInputs = currentCard.querySelectorAll("[required]")
    requiredInputs.forEach(input => {
      if (!input.value.trim()) {
        input.classList.add("input-error")
        input.reportValidity()

        // Remove error class after a delay
        setTimeout(() => {
          input.classList.remove("input-error")
        }, 2000)
      }
    })
  }
}
