// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import consumer from "channels/consumer"

// Import controllers
import ImageUploadController from "controllers/image_upload_controller"
import TagsController from "controllers/tags_controller"
import FlashController from "controllers/flash_controller"
import PricingPlansController from "controllers/pricing_plans_controller"
import CollapsibleController from "controllers/collapsible_controller"
import PriceRangeController from "controllers/price_range_controller"
import InfiniteScrollController from "controllers/infinite_scroll_controller"
import FeaturedSliderController from "controllers/featured_slider_controller"
import CalendarFilterController from "controllers/calendar_filter_controller"
import CalendarController from "controllers/calendar_controller"
import BookingTooltipController from "controllers/booking_tooltip_controller"

// Start Stimulus application
const application = Application.start()
application.register("image-upload", ImageUploadController)
application.register("tags", TagsController)
application.register("flash", FlashController)
application.register("pricing-plans", PricingPlansController)
application.register("collapsible", CollapsibleController)
application.register("price-range", PriceRangeController)
application.register("infinite-scroll", InfiniteScrollController)
application.register("featured-slider", FeaturedSliderController)
application.register("calendar-filter", CalendarFilterController)
application.register("calendar", CalendarController)
application.register("booking-tooltip", BookingTooltipController)

const MODAL_ATTRIBUTE = "data-modal"
const MODAL_VISIBLE_CLASS = "flex"
const MODAL_HIDDEN_CLASS = "hidden"

const DROPDOWN_ATTRIBUTE = "data-dropdown"
const DROPDOWN_MENU_ATTRIBUTE = "data-dropdown-menu"
const DROPDOWN_TOGGLE_ATTRIBUTE = "data-dropdown-toggle"

const STAR_RATING_SELECTOR = "[data-star-rating]"
const STAR_ACTIVE_CLASS = "text-yellow-400"
const STAR_INACTIVE_CLASS = "text-gray-300"
let conversationSubscription = null
let notificationsSubscription = null

const visibleModals = () =>
  Array.from(document.querySelectorAll(`[${MODAL_ATTRIBUTE}]`)).filter(
    (modal) => !modal.classList.contains(MODAL_HIDDEN_CLASS)
  )

const updateBodyScrollLock = () => {
  if (visibleModals().length > 0) {
    document.body.classList.add("overflow-hidden")
  } else {
    document.body.classList.remove("overflow-hidden")
  }
}

const getModal = (id) =>
  document.querySelector(`[${MODAL_ATTRIBUTE}][id="${id}"]`)

const openModal = (id) => {
  const modal = getModal(id)
  if (!modal) return

  modal.classList.remove(MODAL_HIDDEN_CLASS)
  modal.classList.add(MODAL_VISIBLE_CLASS)
  modal.setAttribute("aria-hidden", "false")
  modal.dataset.modalOpen = "true"

  const focusTarget =
    modal.querySelector("[data-modal-focus]") ||
    modal.querySelector("input, button, select, textarea, [href]")

  if (focusTarget instanceof HTMLElement) {
    focusTarget.focus({ preventScroll: true })
  }

  updateBodyScrollLock()
}

const closeModalElement = (modal) => {
  if (!modal) return

  modal.classList.add(MODAL_HIDDEN_CLASS)
  modal.classList.remove(MODAL_VISIBLE_CLASS)
  modal.setAttribute("aria-hidden", "true")
  delete modal.dataset.modalOpen

  updateBodyScrollLock()
}

const closeModal = (id) => closeModalElement(getModal(id))

const toggleDropdown = (dropdown, forceState) => {
  if (!dropdown) return
  const menu = dropdown.querySelector(`[${DROPDOWN_MENU_ATTRIBUTE}]`)
  if (!menu) return

  const shouldOpen =
    typeof forceState === "boolean"
      ? forceState
      : menu.classList.contains("hidden")

  if (shouldOpen) {
    menu.classList.remove("hidden")
    dropdown.dataset.dropdownOpen = "true"
  } else {
    menu.classList.add("hidden")
    delete dropdown.dataset.dropdownOpen
  }
}

const closeAllDropdowns = (exception) => {
  document
    .querySelectorAll(`[${DROPDOWN_ATTRIBUTE}]`)
    .forEach((dropdown) => {
      if (exception && dropdown === exception) return
      toggleDropdown(dropdown, false)
    })
}

const handleDocumentClick = (event) => {
  const modalToggle = event.target.closest("[data-modal-toggle]")
  if (modalToggle) {
    const targetId = modalToggle.getAttribute("data-modal-target")
    const closeId = modalToggle.getAttribute("data-modal-close")

    // Close the specified modal first if it exists
    if (closeId) {
      closeModal(closeId)
    }

    if (targetId) {
      const modal = getModal(targetId)
      if (modal?.dataset.modalOpen === "true") {
        closeModal(targetId)
      } else {
        openModal(targetId)
      }
    }
    event.preventDefault()
    return
  }

  const closeButton = event.target.closest("[data-modal-close]")
  if (closeButton) {
    const explicitTarget = closeButton.getAttribute("data-modal-close")
    const modal = explicitTarget
      ? getModal(explicitTarget)
      : closeButton.closest(`[${MODAL_ATTRIBUTE}]`)

    closeModalElement(modal)
    event.preventDefault()
    return
  }

  const overlay = event.target.closest("[data-modal-overlay]")
  if (overlay) {
    const modal = overlay.closest(`[${MODAL_ATTRIBUTE}]`)
    closeModalElement(modal)
    return
  }

  const dropdownToggle = event.target.closest(
    `[${DROPDOWN_TOGGLE_ATTRIBUTE}]`
  )
  if (dropdownToggle) {
    const dropdown = dropdownToggle.closest(`[${DROPDOWN_ATTRIBUTE}]`)
    if (dropdown) {
      const isOpen = dropdown.dataset.dropdownOpen === "true"
      closeAllDropdowns(dropdown)
      toggleDropdown(dropdown, !isOpen)
    }
    event.preventDefault()
    return
  }

  if (!event.target.closest(`[${DROPDOWN_ATTRIBUTE}]`)) {
    closeAllDropdowns()
  }
}

const handleKeydown = (event) => {
  if (event.key === "Escape") {
    const modals = visibleModals()
    if (modals.length > 0) {
      closeModalElement(modals[modals.length - 1])
    } else {
      closeAllDropdowns()
    }
  }
}

const initializeInteractiveHandlers = () => {
  if (window.__uiHandlersRegistered) {
    updateBodyScrollLock()
    return
  }

  window.__uiHandlersRegistered = true
  document.addEventListener("click", handleDocumentClick)
  document.addEventListener("keydown", handleKeydown)
  updateBodyScrollLock()
}

const setStarRatingValue = (container, value) => {
  const input = container.querySelector("input[type='hidden']")
  if (!input) return

  const numericValue = Number(value)
  if (!Number.isFinite(numericValue)) return

  input.value = numericValue
  container.dataset.currentRating = numericValue

  container.querySelectorAll("[data-star-rating-value]").forEach((button) => {
    const buttonValue = Number(button.dataset.starRatingValue)
    const isActive = Number.isFinite(buttonValue) && buttonValue <= numericValue

    button.classList.toggle(STAR_ACTIVE_CLASS, isActive)
    button.classList.toggle(STAR_INACTIVE_CLASS, !isActive)
    button.setAttribute("aria-pressed", isActive ? "true" : "false")
  })
}

const buttonDefaultValue = (buttons) => {
  const lastButton = buttons[buttons.length - 1]
  return lastButton ? Number(lastButton.dataset.starRatingValue) : 5
}

const initializeStarRatings = () => {
  document.querySelectorAll(STAR_RATING_SELECTOR).forEach((container) => {
    if (container.dataset.starRatingInitialized === "true") return

    const input = container.querySelector("input[type='hidden']")
    const buttons = container.querySelectorAll("[data-star-rating-value]")
    if (!input || buttons.length === 0) return

    buttons.forEach((button) => {
      button.classList.add(STAR_INACTIVE_CLASS)
      button.addEventListener("click", (event) => {
        event.preventDefault()
        setStarRatingValue(container, button.dataset.starRatingValue)
      })
    })

    const initialValue = Number(
      container.dataset.initialRating || input.value || buttonDefaultValue(buttons)
    )
    setStarRatingValue(container, Number.isFinite(initialValue) ? initialValue : 5)

    container.dataset.starRatingInitialized = "true"
  })
}

const onReady = () => {
  initializeInteractiveHandlers()
  initializeStarRatings()
  initializeConversationRealtime()
  initializeConversationComposer()
  initializeNotificationsSubscription()
}

document.addEventListener("turbo:load", onReady)
document.addEventListener("DOMContentLoaded", onReady)

const initializeConversationRealtime = () => {
  const container = document.querySelector("[data-conversation-subscription]")
  if (!container || !container.dataset.conversationSubscription) {
    if (conversationSubscription) {
      conversationSubscription.unsubscribe()
      conversationSubscription = null
    }
    return
  }

  const conversationId = container.dataset.conversationSubscription
  const messagesContainer = container.querySelector("[data-conversation-messages]")
  const currentUserId = Number(container.dataset.currentUserId || document.body.dataset.currentUserId || 0)

  if (!messagesContainer || !conversationId) return

  if (conversationSubscription) {
    conversationSubscription.unsubscribe()
  }

  conversationSubscription = consumer.subscriptions.create(
    { channel: "ConversationChannel", conversation_id: conversationId },
    {
      received(data) {
        appendConversationMessage(messagesContainer, data, currentUserId)
        if (Number(data.user_id) !== currentUserId) {
          markConversationAsRead(conversationId)
        }
      }
    }
  )

  scrollMessagesToBottom(messagesContainer)
}

const appendConversationMessage = (container, data, currentUserId) => {
  if (!container || !data?.body) return

  const isOwnMessage = Number(data.user_id) === Number(currentUserId)
  const wrapper = document.createElement("div")
  wrapper.className = `flex ${isOwnMessage ? "justify-end" : "justify-start"}`
  const bubbleClasses = isOwnMessage
    ? "bg-purple-600 text-white"
    : "bg-white text-gray-900 border border-gray-100"
  const timestampClass = isOwnMessage ? "text-purple-100" : "text-gray-500"

  const bubble = document.createElement("div")
  bubble.className = `max-w-xl rounded-2xl px-4 py-3 shadow-sm ${bubbleClasses}`

  const bodyParagraph = document.createElement("p")
  bodyParagraph.className = "text-sm whitespace-pre-wrap"
  bodyParagraph.textContent = data.body

  const timestamp = document.createElement("p")
  timestamp.className = `text-xs mt-2 ${timestampClass}`
  timestamp.textContent = data.formatted_created_at || ""

  bubble.appendChild(bodyParagraph)
  bubble.appendChild(timestamp)
  wrapper.appendChild(bubble)
  container.appendChild(wrapper)
  if (isOwnMessage) {
    document.querySelector("[data-conversation-form]")?.reset()
  }
  scrollMessagesToBottom(container)
}

const scrollMessagesToBottom = (container) => {
  if (!container) return
  container.scrollTop = container.scrollHeight
}

const markConversationAsRead = (conversationId) => {
  fetch(`/dashboard/conversations/${conversationId}/read`, {
    method: "POST",
    headers: {
      "X-CSRF-Token": getCsrfToken(),
      Accept: "application/json"
    }
  })
    .then((response) => response.json())
    .then((data) => {
      if (typeof data.unread_count === "number") {
        updateUnreadBadge(data.unread_count)
      }
    })
    .catch(() => {})
}

const initializeNotificationsSubscription = () => {
  const currentUserId = document.body.dataset.currentUserId
  if (!currentUserId) {
    if (notificationsSubscription) {
      notificationsSubscription.unsubscribe()
      notificationsSubscription = null
    }
    return
  }

  if (notificationsSubscription) return

  notificationsSubscription = consumer.subscriptions.create(
    { channel: "NotificationsChannel" },
    {
      received(data) {
        if (typeof data.unread_count === "number") {
          updateUnreadBadge(data.unread_count)
        }
      }
    }
  )
}

const updateUnreadBadge = (count) => {
  const normalized = Number(count) || 0
  const badges = document.querySelectorAll("[data-unread-badge]")
  if (badges.length === 0) return

  badges.forEach((badge) => {
    const target = badge.querySelector("[data-unread-count]")
    if (normalized > 0) {
      if (target) {
        target.textContent = normalized
      } else {
        badge.textContent = normalized
      }
      badge.classList.remove("hidden")
      badge.setAttribute("aria-hidden", "false")
    } else {
      if (target) {
        target.textContent = ""
      } else {
        badge.textContent = ""
      }
      badge.classList.add("hidden")
      badge.setAttribute("aria-hidden", "true")
    }
  })
}

const initializeConversationComposer = () => {
  const form = document.querySelector("[data-conversation-form]")
  if (!form || form.dataset.enterSubmitInitialized === "true") return

  const textarea = form.querySelector("textarea")
  if (!textarea) return

  textarea.addEventListener("keydown", (event) => {
    if (event.key !== "Enter" || event.shiftKey || event.isComposing) return

    event.preventDefault()
    const value = textarea.value.trim()
    if (value.length === 0) return

    form.requestSubmit()
  })

  form.dataset.enterSubmitInitialized = "true"
}

const getCsrfToken = () => document.querySelector("meta[name='csrf-token']")?.content || ""
