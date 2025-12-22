class Dashboard::MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: :create

  def create
    return unless @conversation

    unless @conversation.includes_user?(current_user)
      redirect_to dashboard_conversations_path, alert: "Nemate pristup ovoj konverzaciji."
      return
    end

    @message = @conversation.messages.new(message_params.merge(user: current_user))
    respond_to do |format|
      if @message.save
        format.html { redirect_to dashboard_conversations_path(conversation_id: @conversation.id) }
        format.turbo_stream { head :ok }
      else
        format.html { redirect_to dashboard_conversations_path(conversation_id: @conversation.id), alert: @message.errors.full_messages.to_sentence }
        format.turbo_stream { head :unprocessable_entity }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:body)
  end

  def set_conversation
    @conversation = conversation_access_scope.find(params[:conversation_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_conversations_path, alert: "Konverzacija nije pronađena."
    nil
  end
end