import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]
  static values = { defaultOpen: Boolean }

  connect() {
    // Check if content should be open by default (no 'hidden' class or defaultOpen attribute)
    this.isOpen = this.defaultOpenValue || !this.contentTarget.classList.contains("hidden")
    this.updateIcon()
  }

  toggle() {
    this.isOpen = !this.isOpen
    this.contentTarget.classList.toggle("hidden", !this.isOpen)
    this.updateIcon()
  }

  updateIcon() {
    if (!this.hasIconTarget) return
    // When closed (collapsed), arrow points down (rotate 180 degrees)
    // When open (expanded), arrow points up (no rotation)
    if (this.isOpen) {
      this.iconTarget.classList.remove("rotate-180")
    } else {
      this.iconTarget.classList.add("rotate-180")
    }
  }
}
