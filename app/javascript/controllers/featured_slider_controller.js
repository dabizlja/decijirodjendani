import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "prevButton", "nextButton"]

  connect() {
    this.boundUpdateButtons = this.updateButtons.bind(this)
    this.containerTarget.addEventListener("scroll", this.boundUpdateButtons, {
      passive: true
    })
    window.addEventListener("resize", this.boundUpdateButtons)

    // Auto-scroll functionality
    this.autoScrollInterval = null
    this.isPaused = false

    // Start auto-scroll
    this.startAutoScroll()

    // Pause on hover/touch
    this.element.addEventListener("mouseenter", () => this.pauseAutoScroll())
    this.element.addEventListener("mouseleave", () => this.resumeAutoScroll())
    this.element.addEventListener("touchstart", () => this.pauseAutoScroll())
    this.element.addEventListener("touchend", () => this.resumeAutoScroll())

    this.updateButtons()
  }

  disconnect() {
    this.containerTarget.removeEventListener("scroll", this.boundUpdateButtons)
    window.removeEventListener("resize", this.boundUpdateButtons)
    this.stopAutoScroll()
  }

  scrollNext() {
    this.scrollBy(1)
  }

  scrollPrev() {
    this.scrollBy(-1)
  }

  scrollBy(direction) {
    const container = this.containerTarget
    const step = container.clientWidth || 0
    if (step === 0) return

    container.scrollBy({
      left: step * direction,
      behavior: "smooth"
    })

    window.setTimeout(this.boundUpdateButtons, 400)
  }

  // Auto-scroll methods
  startAutoScroll() {
    this.stopAutoScroll() // Clear any existing interval
    this.autoScrollInterval = setInterval(() => {
      if (!this.isPaused) {
        this.autoScrollNext()
      }
    }, 2000) // 2 seconds
  }

  stopAutoScroll() {
    if (this.autoScrollInterval) {
      clearInterval(this.autoScrollInterval)
      this.autoScrollInterval = null
    }
  }

  pauseAutoScroll() {
    this.isPaused = true
  }

  resumeAutoScroll() {
    this.isPaused = false
  }

  autoScrollNext() {
    const container = this.containerTarget
    const scrollLeft = container.scrollLeft
    const maxScrollLeft = container.scrollWidth - container.clientWidth - 4

    // If we're at the end, scroll back to beginning
    if (scrollLeft >= maxScrollLeft) {
      container.scrollTo({
        left: 0,
        behavior: "smooth"
      })
    } else {
      // Otherwise scroll to next
      this.scrollNext()
    }

    window.setTimeout(this.boundUpdateButtons, 400)
  }

  updateButtons() {
    const container = this.containerTarget
    const scrollLeft = container.scrollLeft
    const maxScrollLeft = container.scrollWidth - container.clientWidth - 4

    this.toggleButton(this.prevButtonTarget, scrollLeft <= 4)
    this.toggleButton(this.nextButtonTarget, scrollLeft >= maxScrollLeft)
  }

  toggleButton(button, disabled) {
    if (!button) return
    button.disabled = disabled
    button.classList.toggle("opacity-40", disabled)
    button.classList.toggle("pointer-events-none", disabled)
  }
}
