import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startField", "endField"]

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
    const bookingId = event.currentTarget.dataset.bookingId
    if (!bookingId) return

    // Load booking data via fetch
    this.loadBookingForEdit(bookingId)
  }

  async loadBookingForEdit(bookingId) {
    const container = document.querySelector('#edit-booking-form-container')

    try {
      const response = await fetch(`/dashboard/bookings/${bookingId}/edit`, {
        headers: {
          'Accept': 'text/html',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || ''
        }
      })

      if (response.ok) {
        const html = await response.text()
        if (container) {
          container.innerHTML = html
        }
      } else {
        if (container) {
          container.innerHTML = `
            <div class="text-center py-4">
              <p class="text-red-600 font-medium">Greška pri učitavanju termina</p>
              <p class="text-sm text-gray-500 mt-1">Status: ${response.status}</p>
            </div>
          `
        }
      }
    } catch (error) {
      if (container) {
        container.innerHTML = `
          <div class="text-center py-4">
            <p class="text-red-600 font-medium">Greška pri učitavanju</p>
            <p class="text-sm text-gray-500 mt-1">${error.message}</p>
          </div>
        `
      }
    }
  }

  formatForInput(date) {
    const pad = (num) => String(num).padStart(2, "0")
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(
      date.getDate()
    )}T${pad(date.getHours())}:${pad(date.getMinutes())}`
  }
}
