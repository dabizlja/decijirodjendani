import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    business: String,
    time: String,
    title: String,
    notes: String
  }

  connect() {
    this.tooltip = document.getElementById("booking-tooltip")
    if (!this.tooltip) {
      this.tooltip = document.createElement("div")
      this.tooltip.id = "booking-tooltip"
      this.tooltip.className =
        "hidden fixed z-50 pointer-events-none bg-white text-gray-800 shadow-2xl rounded-xl border border-purple-100 p-4 w-64 text-sm"
      document.body.appendChild(this.tooltip)
    }
  }

  show(event) {
    this.updateContent()
    this.move(event)
    this.tooltip.classList.remove("hidden")
  }

  hide() {
    this.tooltip.classList.add("hidden")
  }

  move(event) {
    const offset = 16
    this.tooltip.style.top = `${event.pageY + offset}px`
    this.tooltip.style.left = `${event.pageX + offset}px`
  }

  updateContent() {
    const notes =
      this.hasNotesValue && this.notesValue.trim().length > 0
        ? `<p class="mt-2 text-xs text-gray-500">${this.notesValue}</p>`
        : ""

    this.tooltip.innerHTML = `
      <div class="text-xs font-semibold text-purple-600 uppercase tracking-wide mb-1">Termin</div>
      <p class="text-base font-semibold text-gray-900">${this.businessValue}</p>
      <p class="text-sm text-purple-700 font-medium mt-1">${this.timeValue}</p>
      <p class="mt-2 text-sm text-gray-700">${this.titleValue}</p>
      ${notes}
    `
  }
}
