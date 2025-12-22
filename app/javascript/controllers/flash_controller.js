import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    timeout: { type: Number, default: 5000 }
  }

  connect() {
    this.startTimer()
  }

  disconnect() {
    this.stopTimer()
  }

  dismiss() {
    this.stopTimer()
    this.element.classList.add("opacity-0", "-translate-y-1")
    setTimeout(() => this.element.remove(), 200)
  }

  startTimer() {
    if (this.timeoutValue <= 0) return
    this.timer = setTimeout(() => this.dismiss(), this.timeoutValue)
  }

  stopTimer() {
    if (this.timer) {
      clearTimeout(this.timer)
      this.timer = null
    }
  }
}
