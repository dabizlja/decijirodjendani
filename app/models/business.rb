class Business < ApplicationRecord
  belongs_to :user
  belongs_to :category
  belongs_to :city

  has_many :business_tags, dependent: :destroy
  has_many :tags, through: :business_tags
  has_many :business_views, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :pricing_plans, dependent: :destroy
  has_many :discounts, through: :pricing_plans
  has_many :bookings, dependent: :destroy

  has_many_attached :images
  accepts_nested_attributes_for :pricing_plans, allow_destroy: true

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, length: { maximum: 1000 }
  validates :phone, format: { with: /\A[\+\d\s\-\(\)]+\z/, message: "nije valjan format" }, allow_blank: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true
  validates :slug, presence: true, uniqueness: true

  validate :validate_images
  validate :validate_pricing_plans

  before_validation :generate_slug, if: :should_generate_new_slug?

  scope :active, -> { where(active: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_city, ->(city) { where(city: city) }

  def self.price_bounds
    # Get all base_price values from pricing plans
    prices = PricingPlan.pluck(:base_price).compact

    return { min: 0, max: 70000 } if prices.empty?

    { min: 0, max: prices.max }
  end

  def main_image
    images.attached? ? images.first : nil
  end

  def display_name
    name.presence || "Bez naziva"
  end

  def resized_images(size = :medium)
    return [] unless images.attached?

    images.map do |image|
      case size
      when :thumbnail
        image.variant(resize_to_limit: [150, 150])
      when :medium
        image.variant(resize_to_limit: [400, 300])
      when :large
        image.variant(resize_to_limit: [800, 600])
      else
        image
      end
    end
  end

  # Analytics methods
  def total_views
    business_views.count
  end

  def views_this_month
    business_views.this_month.count
  end

  def views_this_week
    business_views.this_week.count
  end

  def views_today
    business_views.today.count
  end


  def average_rating
    reviews.average(:rating)&.round(1) || 0.0
  end

  def reviews_count
    reviews.count
  end

  def owner
    user
  end

  def analytics_summary(period = :month)
    case period
    when :today
      {
        views: views_today,
        images_count: images.attached? ? images.count : 0,
        tags_count: tags.count
      }
    when :week
      {
        views: views_this_week,
        images_count: images.attached? ? images.count : 0,
        tags_count: tags.count
      }
    when :month
      {
        views: views_this_month,
        images_count: images.attached? ? images.count : 0,
        tags_count: tags.count
      }
    end
  end

  def refresh_price_cache!
    prices = pricing_plans.active.map(&:current_price).compact
    update_columns(
      min_price: prices.min,
      max_price: prices.max,
      price_currency: pricing_plans.first&.currency || price_currency || "EUR",
      has_active_discount: discounts.active.current.exists?
    )
  end

  def to_param
    slug
  end

  private

  def should_generate_new_slug?
    slug.blank? || name_changed?
  end

  def generate_slug
    return unless name.present?

    base_slug = name.to_s
                   .strip
                   .downcase
                   .gsub(/[^\p{L}\p{N}\s\-_]/, '') # Remove special chars except letters, numbers, spaces, hyphens, underscores
                   .gsub(/\s+/, '-')                # Replace spaces with hyphens
                   .gsub(/-+/, '-')                 # Replace multiple hyphens with single
                   .gsub(/^-+|-+$/, '')             # Remove leading/trailing hyphens

    # Handle empty slug
    base_slug = 'venue' if base_slug.blank?

    # Ensure uniqueness
    candidate_slug = base_slug
    counter = 1

    while Business.where(slug: candidate_slug).where.not(id: id).exists?
      candidate_slug = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = candidate_slug
  end

  def validate_images
    return unless images.attached?

    images.each do |image|
      # Check content type
      unless image.content_type.in?(%w[image/png image/jpg image/jpeg image/webp])
        errors.add(:images, "mora biti PNG, JPG, JPEG ili WebP format")
      end

      # Check file size (5MB limit)
      if image.byte_size > 5.megabytes
        errors.add(:images, "mora biti manja od 5MB")
      end
    end
  end

  def validate_pricing_plans
    # Check if there's at least one pricing plan that won't be destroyed
    valid_plans = pricing_plans.reject(&:marked_for_destruction?)

    if valid_plans.empty?
      errors.add(:base, "Morate dodati bar jedan paket/ponudu za vaš biznis")
    end
  end
end
