class BusinessView < ApplicationRecord
  belongs_to :business

  validates :ip_address, presence: true

  scope :recent, -> { where(created_at: 1.month.ago..) }
  scope :today, -> { where(created_at: Date.current.all_day) }
  scope :this_week, -> { where(created_at: 1.week.ago..) }
  scope :this_month, -> { where(created_at: 1.month.ago..) }

  # Prevent duplicate views from same IP within short timeframe
  def self.track_view(business, request)
    ip = request.remote_ip
    user_agent = request.user_agent
    referer = request.referer

    # Only create view if no recent view from same IP (within 30 minutes)
    last_view = where(business: business, ip_address: ip)
                  .where('created_at > ?', 30.minutes.ago)
                  .exists?

    unless last_view
      create(
        business: business,
        ip_address: ip,
        user_agent: user_agent,
        referer: referer
      )
    end
  rescue StandardError => e
    Rails.logger.error "Failed to track view: #{e.message}"
  end
end
