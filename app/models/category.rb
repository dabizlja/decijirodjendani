class Category < ApplicationRecord
  has_many :businesses, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :icon, presence: true
end
