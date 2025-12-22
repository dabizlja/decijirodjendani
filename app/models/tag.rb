class Tag < ApplicationRecord
  has_many :business_tags, dependent: :destroy
  has_many :businesses, through: :business_tags

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug

  scope :ordered, -> { order(:name) }

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize if name.present?
  end
end
