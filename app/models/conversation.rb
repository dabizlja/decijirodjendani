class Conversation < ApplicationRecord
  belongs_to :business
  belongs_to :customer, class_name: "User"

  has_many :messages, dependent: :destroy

  validates :business, :customer, presence: true
  validates :customer_id, uniqueness: { scope: :business_id }

  scope :recent, -> { order(last_message_at: :desc).order(created_at: :desc) }

  def participants
    [business.user, customer]
  end

  def includes_user?(user)
    user.present? && participants.include?(user)
  end

  def unread_messages_for(user)
    messages.where(read_at: nil).where.not(user: user)
  end
end
