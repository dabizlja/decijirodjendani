class City < ApplicationRecord
  has_many :businesses, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
