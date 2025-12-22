class ConversationChannel < ApplicationCable::Channel
  def subscribed
    @conversation = Conversation.find_by(id: params[:conversation_id])
    reject unless @conversation&.includes_user?(current_user)

    stream_for @conversation
  end
end
