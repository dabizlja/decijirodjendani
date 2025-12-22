import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "option", "selectedCount"]

  connect() {
    this.updateSelectedCount()
  }

  filter() {
    if (!this.hasSearchTarget) return
    const term = this.searchTarget.value.toLowerCase().trim()

    this.optionTargets.forEach((option) => {
      const tagName = option.dataset.tagName || ""
      const matches = !term || tagName.includes(term)
      option.classList.toggle("hidden", !matches)
    })
  }

  toggle() {
    this.updateSelectedCount()
  }

  updateSelectedCount() {
    const selectedOptions = this.optionTargets.filter((option) => {
      const checkbox = option.querySelector('input[type="checkbox"]')
      return checkbox && checkbox.checked
    })

    if (this.hasSelectedCountTarget) {
      this.selectedCountTarget.textContent = selectedOptions.length
    }
  }
}
