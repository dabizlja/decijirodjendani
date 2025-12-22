class PricingPlan < ApplicationRecord
  belongs_to :business
  has_many :discounts, dependent: :destroy

  enum :plan_type, {
    time_slot: 0,
    package: 1,
    service: 2,
    addon: 3
  }

  accepts_nested_attributes_for :discounts, allow_destroy: true, reject_if: :all_blank

  validates :name, :plan_type, :base_price, :currency, presence: true
  validates :base_price, numericality: { greater_than_or_equal_to: 0 }
  validates :capacity_kids, :capacity_adults, :minimum_quantity, :maximum_quantity,
            numericality: { allow_nil: true, greater_than_or_equal_to: 0 }

  before_validation :fallback_currency
  after_commit :update_business_price_cache

  scope :active, -> { where(active: true) }

  def current_price
    discount = active_discount
    return base_price unless discount

    discount.apply_to(base_price)
  end

  def effective_price
    current_price
  end

  def discounted?
    active_discount.present? && effective_price < base_price
  end

  def active_discount
    discounts.active.current.first
  end

  private

  def update_business_price_cache
    business&.refresh_price_cache!
  end

  def fallback_currency
    self.currency ||= business&.price_currency || "EUR"
  end
end
