class Review < ApplicationRecord
  belongs_to :user
  belongs_to :business

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true, length: { maximum: 1000 }
  validates :user_id, uniqueness: { scope: :business_id, message: "je već ostavio recenziju za ovaj biznis" }

  scope :recent, -> { order(created_at: :desc) }
end
