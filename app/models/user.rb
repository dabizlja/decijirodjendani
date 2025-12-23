class User < ApplicationRecord
  attr_accessor :terms_of_service

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :businesses, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :customer_conversations,
           class_name: "Conversation",
           foreign_key: :customer_id,
           dependent: :destroy
  has_many :owned_conversations,
           through: :businesses,
           source: :conversations
  has_many :bookings, through: :businesses
  has_many :customer_bookings,
           class_name: "Booking",
           foreign_key: :customer_id,
           inverse_of: :customer,
           dependent: :nullify

  validates :full_name, presence: true, length: { maximum: 120 }
  validates :terms_of_service, acceptance: true, on: :create

  def self.from_omniauth(auth)
    info = auth.info
    email = info.email.presence || "#{auth.uid}@google-oauth2.local"

    user = find_by(provider: auth.provider, uid: auth.uid)
    user ||= find_by(email: email)
    user ||= new(email: email)

    user.email = email if user.email.blank?
    user.full_name = info.name.presence || email.split("@").first&.tr(".", " ")&.titleize || "Google korisnik"
    user.provider = auth.provider
    user.uid = auth.uid
    user.avatar_url = info.image if info.image.present?
    user.password = Devise.friendly_token.first(20) if user.encrypted_password.blank?
    user.terms_of_service = true

    user.save!
    user
  end

  def all_conversations
    owned_scope = Conversation.where(business: businesses)
    Conversation.where(customer: self).or(owned_scope)
  end

  def unread_messages_count
    Message.where(conversation_id: all_conversations.select(:id))
           .where(read_at: nil)
           .where.not(user_id: id)
           .count
  end
end
