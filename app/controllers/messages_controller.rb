class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business_for_customer_message, only: :create_for_business

  def create_for_business
    return unless @business

    if @business.user == current_user
      redirect_to venue_path(@business), alert: "Ne možete slati poruke sopstvenom biznisu."
      return
    end

    @conversation = Conversation.find_or_create_by!(business: @business, customer: current_user)
    @message = @conversation.messages.new(message_params.merge(user: current_user))

    if @message.save
      redirect_to venue_path(@business), notice: "Poruka je poslata vlasniku."
    else
      redirect_to venue_path(@business), alert: @message.errors.full_messages.to_sentence
    end
  end

  private

  def message_params
    params.require(:message).permit(:body)
  end

  def set_business_for_customer_message
    @business = Business.active.find(params[:business_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to venues_path, alert: "Biznis nije pronađen."
    nil
  end
end
