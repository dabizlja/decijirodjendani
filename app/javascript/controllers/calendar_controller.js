import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startField", "endField", "editFormContainer", "editModalTrigger"]

  openModalForDate(event) {
    const isoDate = event.currentTarget.dataset.date
    if (!isoDate) return

    const start = new Date(isoDate)
    start.setHours(10, 0, 0, 0)
    const end = new Date(start.getTime() + 2 * 60 * 60 * 1000)

    if (this.hasStartFieldTarget) {
      this.startFieldTarget.value = this.formatForInput(start)
    }

    if (this.hasEndFieldTarget) {
      this.endFieldTarget.value = this.formatForInput(end)
    }

    const button = document.querySelector(
      "[data-modal-target='booking-modal']"
    )
    if (button) {
      button.click()
    }
  }

  openEditModal(event) {
    event.preventDefault()
    const bookingId = event.currentTarget.dataset.bookingId
    if (!bookingId) return

    const calendarContext = {
      calendar_month: event.currentTarget.dataset.calendarMonth,
      calendar_year: event.currentTarget.dataset.calendarYear,
      calendar_business_id: event.currentTarget.dataset.calendarBusiness
    }

    this.triggerEditModal()
    this.showEditLoadingState()
    this.loadBookingForEdit(bookingId, calendarContext)
  }

  async loadBookingForEdit(bookingId, calendarContext = {}) {
    if (!this.hasEditFormContainerTarget) return
    const container = this.editFormContainerTarget

    try {
      const query = this.buildQueryString(calendarContext)
      const url =
        query.length > 0
          ? `/dashboard/bookings/${bookingId}/edit?${query}`
          : `/dashboard/bookings/${bookingId}/edit`
      const response = await fetch(url, {
        headers: {
          Accept: "text/html",
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRF-Token":
            document.querySelector('meta[name="csrf-token"]')?.content || ""
        }
      })

      if (response.ok) {
        const html = await response.text()
        container.innerHTML = html
      } else {
        container.innerHTML = `
          <div class="text-center py-4">
            <p class="text-red-600 font-medium">Greška pri učitavanju termina</p>
            <p class="text-sm text-gray-500 mt-1">Status: ${response.status}</p>
          </div>
        `
      }
    } catch (error) {
      container.innerHTML = `
        <div class="text-center py-4">
          <p class="text-red-600 font-medium">Greška pri učitavanju</p>
          <p class="text-sm text-gray-500 mt-1">${error.message}</p>
        </div>
      `
    }
  }

  buildQueryString(context = {}) {
    return Object.entries(context)
      .filter(([, value]) => value !== undefined)
      .map(([key, value]) => {
        const normalized = value ?? ""
        return `${encodeURIComponent(key)}=${encodeURIComponent(normalized)}`
      })
      .join("&")
  }

  showEditLoadingState() {
    if (!this.hasEditFormContainerTarget) return
    this.editFormContainerTarget.innerHTML = `
      <div class="text-center py-4">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600 mx-auto"></div>
        <p class="text-sm text-gray-500 mt-2">Učitava...</p>
      </div>
    `
  }

  triggerEditModal() {
    if (this.hasEditModalTriggerTarget) {
      this.editModalTriggerTarget.click()
    } else {
      document
        .querySelector("[data-modal-target='edit-booking-modal']")
        ?.click()
    }
  }

  formatForInput(date) {
    const pad = (num) => String(num).padStart(2, "0")
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(
      date.getDate()
    )}T${pad(date.getHours())}:${pad(date.getMinutes())}`
  }
}
