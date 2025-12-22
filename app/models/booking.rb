class Booking < ApplicationRecord
  belongs_to :business

  delegate :user, to: :business

  STATUSES = %w[confirmed tentative cancelled].freeze

  validates :title, presence: true, length: { maximum: 120 }
  validates :start_time, :end_time, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :end_after_start

  scope :between, ->(from_time, to_time) {
    where("(start_time < ?) AND (end_time > ?)", to_time, from_time)
  }

  def duration_in_minutes
    return 0 unless start_time && end_time
    ((end_time - start_time) / 60).to_i
  end

  private

  def end_after_start
    return if start_time.blank? || end_time.blank?
    errors.add(:end_time, "mora biti posle vremena početka") if end_time <= start_time
  end
end
