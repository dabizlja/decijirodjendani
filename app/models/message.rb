class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :body, presence: true, length: { maximum: 2000 }

  after_create_commit :touch_conversation
  after_create_commit :broadcast_creation

  scope :unread, -> { where(read_at: nil) }

  def read!
    update(read_at: Time.current) unless read_at?
  end

  private

  def touch_conversation
    conversation.update(last_message_at: created_at)
  end

  def broadcast_creation
    ConversationChannel.broadcast_to(conversation, {
      id: id,
      body: body,
      user_id: user_id,
      formatted_created_at: I18n.l(created_at, format: "%d.%m.%Y. %H:%M")
    })

    conversation.participants.each do |participant|
      next unless participant

      NotificationsChannel.broadcast_to(participant, {
        unread_count: participant.unread_messages_count
      })
    end
  end
end
