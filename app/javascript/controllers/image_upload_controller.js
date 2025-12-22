import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  connect() {
    console.log("Image upload controller connected")
  }

  addField() {
    const template = this.templateTarget.content.cloneNode(true)
    this.containerTarget.appendChild(template)
  }

  removeField(event) {
    event.target.closest('.image-field').remove()
  }
}