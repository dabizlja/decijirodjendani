import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "plan"]

  add(event) {
    event.preventDefault()
    const template = this.buildTemplate()
    this.listTarget.insertAdjacentHTML("beforeend", template)
  }

  remove(event) {
    event.preventDefault()
    const planElement = event.target.closest("[data-pricing-plans-target='plan']")
    if (planElement) planElement.remove()
  }

  buildTemplate() {
    const timestamp = new Date().getTime()
    const planIndex = this.element.dataset.nextIndex
      ? Number(this.element.dataset.nextIndex)
      : timestamp
    this.element.dataset.nextIndex = planIndex + 1

    return `
      <div class="rounded-2xl border border-gray-200 bg-gradient-to-br from-white to-gray-50 p-5 space-y-4" data-pricing-plans-target="plan">
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
          <div>
            <p class="text-sm font-semibold text-gray-700">Nova ponuda</p>
            <p class="text-xs text-gray-500">Tip ponude: termin, paket, usluga ili dodatak.</p>
          </div>
          <button type="button" class="inline-flex items-center gap-2 text-sm text-red-600" data-action="pricing-plans#remove">
            🗑️ Ukloni
          </button>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-1">Naziv paketa</label>
            <input type="text" name="business[pricing_plans_attributes][${planIndex}][name]" class="w-full rounded-xl border-2 border-gray-200 px-4 py-2.5 focus:border-purple-500 focus:outline-none" placeholder="npr. Termin 2.5h + torta">
          </div>
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-1">Tip ponude</label>
            <select name="business[pricing_plans_attributes][${planIndex}][plan_type]" class="w-full rounded-xl border-2 border-gray-200 px-4 py-2.5 focus:border-purple-500 focus:outline-none bg-white">
              <option value="time_slot">Termin</option>
              <option value="package">Paket</option>
              <option value="service">Usluga</option>
              <option value="addon">Dodatna opcija</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-1">Cena</label>
            <div class="flex gap-2">
              <input type="number" min="0" step="1" name="business[pricing_plans_attributes][${planIndex}][base_price]" class="flex-1 rounded-xl border-2 border-gray-200 px-4 py-2.5 focus:border-purple-500 focus:outline-none" placeholder="npr. 150">
              <select name="business[pricing_plans_attributes][${planIndex}][currency]" class="w-32 rounded-xl border-2 border-gray-200 px-3 py-2.5 focus:border-purple-500 focus:outline-none bg-white">
                <option value="RSD">RSD</option>
                <option value="EUR">EUR</option>
              </select>
            </div>
          </div>
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-1">Trajanje (min)</label>
            <input type="number" min="0" step="15" name="business[pricing_plans_attributes][${planIndex}][duration_minutes]" class="w-full rounded-xl border-2 border-gray-200 px-4 py-2.5 focus:border-purple-500 focus:outline-none" placeholder="npr. 150">
          </div>
        </div>
        <div class="bg-purple-50 border border-purple-100 rounded-2xl p-4" data-controller="collapsible">
          <div class="flex items-center justify-between">
            <p class="text-sm font-semibold text-purple-800 flex items-center gap-2 mb-3">
              <span>🏷️</span>
              Popust (opciono)
            </p>
            <button type="button" class="text-sm font-semibold text-purple-700" data-action="collapsible#toggle" data-collapsible-target="toggle">
              Prikaži
            </button>
          </div>
          <div class="hidden space-y-4" data-collapsible-target="content">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Naziv popusta</label>
                <input type="text" name="business[pricing_plans_attributes][${planIndex}][discounts_attributes][0][name]" class="w-full rounded-xl border-2 border-gray-200 px-4 py-2.5 focus:border-purple-500 focus:outline-none">
              </div>
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Natpis za korisnike</label>
                <input type="text" name="business[pricing_plans_attributes][${planIndex}][discounts_attributes][0][label]" class="w-full rounded-xl border-2 border-gray-200 px-4 py-2.5 focus:border-purple-500 focus:outline-none">
              </div>
            </div>
          </div>
        </div>
      </div>
    `
  }
}
