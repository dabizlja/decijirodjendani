class Dashboard::ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    scope = conversation_access_scope
    @conversations = scope.includes(:business, :customer, messages: :user).recent
    @selected_conversation = if params[:conversation_id]
                               @conversations.find { |conv| conv.id == params[:conversation_id].to_i }
                             else
                               @conversations.first
                             end
    @new_message = Message.new

    mark_selected_conversation_as_read
  end

  def read
    conversation = conversation_access_scope.find(params[:id])
    conversation.unread_messages_for(current_user).find_each(&:read!)
    unread_count = current_user.unread_messages_count
    NotificationsChannel.broadcast_to(current_user, { unread_count: unread_count })

    respond_to do |format|
      format.json { render json: { unread_count: unread_count } }
      format.html { redirect_to dashboard_conversations_path(conversation_id: conversation.id) }
    end
  end

  private

  def mark_selected_conversation_as_read
    return unless @selected_conversation

    @selected_conversation.unread_messages_for(current_user).find_each(&:read!)
  end
end