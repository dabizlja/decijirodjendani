class Discount < ApplicationRecord
  belongs_to :pricing_plan

  validates :percentage_off, numericality: { greater_than: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :amount_off, numericality: { greater_than: 0 }, allow_nil: true
  validate :percentage_or_amount_present
  validate :ends_after_start

  scope :active, -> { where(active: true) }
  scope :current, lambda {
    now = Time.current
    where("starts_at IS NULL OR starts_at <= ?", now)
      .where("ends_at IS NULL OR ends_at >= ?", now)
  }

  after_commit :refresh_business_cache

  def apply_to(amount)
    return amount unless active? && currently_active?

    discounted = amount
    discounted -= (amount * percentage_off / 100.0) if percentage_off.present?
    discounted -= amount_off.to_d if amount_off.present?
    discounted.positive? ? discounted : 0
  end

  def currently_active?
    now = Time.current
    (starts_at.nil? || starts_at <= now) && (ends_at.nil? || ends_at >= now)
  end

  private

  def percentage_or_amount_present
    return if percentage_off.present? || amount_off.present?

    errors.add(:base, "Popust mora imati procenat ili iznos")
  end

  def ends_after_start
    return if starts_at.blank? || ends_at.blank?
    return if ends_at >= starts_at

    errors.add(:ends_at, "mora biti posle datuma početka")
  end

  def refresh_business_cache
    pricing_plan&.business&.refresh_price_cache!
  end
end
