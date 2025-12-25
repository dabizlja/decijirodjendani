import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "thumbnail", "lightbox", "lightboxImage", "counter", "prevBtn", "nextBtn"]
  static values = { currentIndex: Number }

  connect() {
    this.currentIndexValue = 0
    this.totalImages = this.thumbnailTargets.length

    // Set up touch/swipe support
    this.setupTouchEvents()

    // Keyboard navigation
    this.boundKeyHandler = this.handleKeydown.bind(this)

    // Touch listeners flag
    this.touchListenersAdded = false
  }

  disconnect() {
    this.removeTouchEvents()
  }

  // Open lightbox with specific image
  openLightbox(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.currentIndexValue = index
    this.showLightbox()
    this.updateLightboxImage()

    // Add keyboard listener when lightbox opens
    document.addEventListener('keydown', this.boundKeyHandler)

    // Prevent body scroll
    document.body.style.overflow = 'hidden'
  }

  // Close lightbox
  closeLightbox(event) {
    if (event) event.stopPropagation()

    this.lightboxTarget.classList.add('hidden')
    this.lightboxTarget.classList.remove('flex')

    // Remove keyboard listener
    document.removeEventListener('keydown', this.boundKeyHandler)

    // Restore body scroll
    document.body.style.overflow = ''
  }

  // Show lightbox
  showLightbox() {
    this.lightboxTarget.classList.remove('hidden')
    this.lightboxTarget.classList.add('flex')
  }

  // Navigate to previous image
  previousImage(event) {
    if (event) event.stopPropagation()
    this.currentIndexValue = (this.currentIndexValue - 1 + this.totalImages) % this.totalImages
    this.updateLightboxImage()
  }

  // Navigate to next image
  nextImage(event) {
    if (event) event.stopPropagation()
    this.currentIndexValue = (this.currentIndexValue + 1) % this.totalImages
    this.updateLightboxImage()
  }

  // Update the displayed image in lightbox
  updateLightboxImage() {
    // Hide all images
    this.lightboxImageTargets.forEach((img, index) => {
      if (index === this.currentIndexValue) {
        img.classList.remove('hidden')
        img.classList.add('block')
      } else {
        img.classList.add('hidden')
        img.classList.remove('block')
      }
    })

    // Update counter
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${this.currentIndexValue + 1} / ${this.totalImages}`
    }

    // Update navigation buttons
    this.updateNavigationButtons()
  }

  // Update navigation button states
  updateNavigationButtons() {
    if (!this.hasPrevBtnTarget || !this.hasNextBtnTarget) return

    // For infinite loop, buttons are always enabled
    this.prevBtnTarget.disabled = false
    this.nextBtnTarget.disabled = false
    this.prevBtnTarget.classList.remove('opacity-50')
    this.nextBtnTarget.classList.remove('opacity-50')
  }

  // Keyboard navigation
  handleKeydown(event) {
    switch(event.key) {
      case 'Escape':
        this.closeLightbox()
        break
      case 'ArrowLeft':
        this.previousImage()
        break
      case 'ArrowRight':
        this.nextImage()
        break
    }
  }

  // Touch/swipe support
  setupTouchEvents() {
    this.startX = 0
    this.startY = 0
    this.isSwipeActionHandled = false

    this.touchStartHandler = this.handleTouchStart.bind(this)
    this.touchMoveHandler = this.handleTouchMove.bind(this)
    this.touchEndHandler = this.handleTouchEnd.bind(this)
  }

  removeTouchEvents() {
    if (this.lightboxTarget) {
      this.lightboxTarget.removeEventListener('touchstart', this.touchStartHandler)
      this.lightboxTarget.removeEventListener('touchmove', this.touchMoveHandler)
      this.lightboxTarget.removeEventListener('touchend', this.touchEndHandler)
    }
  }

  handleTouchStart(event) {
    this.startX = event.touches[0].clientX
    this.startY = event.touches[0].clientY
    this.isSwipeActionHandled = false
  }

  handleTouchMove(event) {
    if (this.isSwipeActionHandled) return

    const currentX = event.touches[0].clientX
    const currentY = event.touches[0].clientY

    const diffX = this.startX - currentX
    const diffY = this.startY - currentY

    // Only handle horizontal swipes (ignore vertical scrolling)
    if (Math.abs(diffX) > Math.abs(diffY) && Math.abs(diffX) > 30) {
      event.preventDefault()

      if (diffX > 0) {
        // Swipe left - next image
        this.nextImage()
      } else {
        // Swipe right - previous image
        this.previousImage()
      }

      this.isSwipeActionHandled = true
    }
  }

  handleTouchEnd(event) {
    // Reset swipe tracking
    this.startX = 0
    this.startY = 0
  }

  // Set up touch events when lightbox is shown
  currentIndexValueChanged() {
    if (this.hasLightboxTarget && !this.lightboxTarget.classList.contains('hidden')) {
      // Add touch listeners if not already added
      if (!this.touchListenersAdded) {
        this.lightboxTarget.addEventListener('touchstart', this.touchStartHandler, { passive: false })
        this.lightboxTarget.addEventListener('touchmove', this.touchMoveHandler, { passive: false })
        this.lightboxTarget.addEventListener('touchend', this.touchEndHandler, { passive: false })
        this.touchListenersAdded = true
      }
    }
  }
}