import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "prevButton", "nextButton"]

  connect() {
    this.boundUpdateButtons = this.updateButtons.bind(this)
    this.containerTarget.addEventListener("scroll", this.boundUpdateButtons, {
      passive: true
    })
    window.addEventListener("resize", this.boundUpdateButtons)
    this.updateButtons()
  }

  disconnect() {
    this.containerTarget.removeEventListener("scroll", this.boundUpdateButtons)
    window.removeEventListener("resize", this.boundUpdateButtons)
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
