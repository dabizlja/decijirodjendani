import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loading", "container"]
  static values = {
    loading: { type: Boolean, default: false },
    hasMore: { type: Boolean, default: true },
    nextPage: { type: Number, default: 2 }
  }

  connect() {
    this.observer = new IntersectionObserver(this.handleIntersect.bind(this), {
      root: null,
      rootMargin: "50px",
      threshold: 0.1
    })

    if (this.hasLoadingTarget) {
      this.observer.observe(this.loadingTarget)
    }
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  handleIntersect(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting && this.hasMoreValue && !this.loadingValue) {
        this.loadMore()
      }
    })
  }

  async loadMore() {
    if (this.loadingValue || !this.hasMoreValue) return

    this.loadingValue = true
    this.showLoading()

    try {
      const url = new URL(window.location)
      url.searchParams.set('page', this.nextPageValue)

      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Accept': 'text/vnd.turbo-stream.html',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (response.ok) {
        const html = await response.text()

        // Use Turbo to handle the response
        if (window.Turbo) {
          Turbo.renderStreamMessage(html)
        }

        this.nextPageValue += 1
      } else {
        console.error('Failed to load more items')
        this.hasMoreValue = false
      }
    } catch (error) {
      console.error('Error loading more items:', error)
      this.hasMoreValue = false
    } finally {
      this.loadingValue = false
      this.hideLoading()
    }
  }

  showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove('hidden')
    }
  }

  hideLoading() {
    if (this.hasLoadingTarget && !this.hasMoreValue) {
      this.loadingTarget.classList.add('hidden')
    }
  }

  noMoreItems() {
    this.hasMoreValue = false
    this.hideLoading()
  }
}