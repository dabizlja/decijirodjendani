class PaymentDetail < ApplicationRecord
  belongs_to :user

  validates :bank_account_number, presence: true, length: { minimum: 8, maximum: 30 }
  validates :account_owner_name, presence: true, length: { maximum: 100 }
  validates :account_owner_address, presence: true, length: { maximum: 500 }

  # Ensure only one payment detail per user
  validates :user_id, uniqueness: true
end
