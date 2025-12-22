class BusinessInquiry < ApplicationRecord
  belongs_to :business

  validates :inquiry_type, presence: true
  validates :contact_method, presence: true

  # Inquiry types
  INQUIRY_TYPES = %w[
    phone_click
    email_click
    website_click
    contact_form
    direct_message
  ].freeze

  # Contact methods
  CONTACT_METHODS = %w[
    phone
    email
    website
    form
    chat
  ].freeze

  validates :inquiry_type, inclusion: { in: INQUIRY_TYPES }
  validates :contact_method, inclusion: { in: CONTACT_METHODS }

  scope :recent, -> { where(created_at: 1.month.ago..) }
  scope :by_type, ->(type) { where(inquiry_type: type) }
  scope :by_method, ->(method) { where(contact_method: method) }

  def self.track_inquiry(business, type, method, request = nil)
    attributes = {
      business: business,
      inquiry_type: type,
      contact_method: method
    }

    if request
      attributes[:user_ip] = request.remote_ip
      attributes[:user_agent] = request.user_agent
    end

    create(attributes)
  rescue StandardError => e
    Rails.logger.error "Failed to track inquiry: #{e.message}"
  end
end
