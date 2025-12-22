import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["minSlider", "maxSlider", "progress", "minLabel", "maxLabel"]
  static values = {
    min: Number,
    max: Number,
    defaultMin: Number,
    defaultMax: Number,
    step: { type: Number, default: 50 },
    currency: { type: String, default: "RSD" }
  }

  connect() {
    this.minBound = this.minValue || 0
    this.maxBound = this.maxValue || 2000
    const initialMin = this.defaultMinValue || this.minBound
    const initialMax = this.defaultMaxValue || this.maxBound

    this.setupSlider(this.minSliderTarget, initialMin)
    this.setupSlider(this.maxSliderTarget, initialMax)
    this.updateDisplay()
  }

  setupSlider(slider, value) {
    slider.min = this.minBound
    slider.max = this.maxBound
    slider.step = this.stepValue
    slider.value = this.clamp(value)
  }

  updateFromSlider(event) {
    let minValue = Number(this.minSliderTarget.value)
    let maxValue = Number(this.maxSliderTarget.value)

    // Ensure min doesn't exceed max and vice versa
    if (event.target === this.minSliderTarget) {
      if (minValue > maxValue) {
        this.minSliderTarget.value = maxValue
        minValue = maxValue
      }
    } else {
      if (maxValue < minValue) {
        this.maxSliderTarget.value = minValue
        maxValue = minValue
      }
    }

    // Update z-index for proper layering when sliders overlap
    if (minValue === maxValue) {
      if (event.target === this.minSliderTarget) {
        this.minSliderTarget.style.zIndex = "3"
        this.maxSliderTarget.style.zIndex = "2"
      } else {
        this.maxSliderTarget.style.zIndex = "3"
        this.minSliderTarget.style.zIndex = "2"
      }
    } else {
      this.minSliderTarget.style.zIndex = "2"
      this.maxSliderTarget.style.zIndex = "2"
    }

    this.updateDisplay()
  }

  updateDisplay() {
    const minValue = Number(this.minSliderTarget.value)
    const maxValue = Number(this.maxSliderTarget.value)

    // Update labels
    if (this.hasMinLabelTarget) this.minLabelTarget.textContent = this.format(minValue)
    if (this.hasMaxLabelTarget) this.maxLabelTarget.textContent = this.format(maxValue)

    // Update progress bar
    const range = this.maxBound - this.minBound
    const left = ((minValue - this.minBound) / range) * 100
    const right = 100 - ((maxValue - this.minBound) / range) * 100

    if (this.hasProgressTarget) {
      this.progressTarget.style.left = `${left}%`
      this.progressTarget.style.right = `${right}%`
    }
  }

  clamp(value) {
    return Math.min(Math.max(value, this.minBound), this.maxBound)
  }

  format(value) {
    return `${Math.round(value)} ${this.currencyValue}`
  }
}
