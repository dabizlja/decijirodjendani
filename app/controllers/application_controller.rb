class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_user_location!, if: :storable_location?
  before_action :set_user_role, if: :user_signed_in?
  before_action :set_header_notifications, if: :user_signed_in?

  helper_method :business_owner?

  protected

  def configure_permitted_parameters
    additional_attrs = [ :full_name, :terms_of_service ]
    devise_parameter_sanitizer.permit(:sign_up, keys: additional_attrs)
    devise_parameter_sanitizer.permit(:account_update, keys: additional_attrs + [ :avatar_url ])
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || dashboard_root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  private

  def set_header_notifications
    scope = conversation_access_scope
    return unless scope.exists?

    conversation_ids = scope.select(:id)
    @unread_messages_count = Message.where(conversation_id: conversation_ids)
                                    .where(read_at: nil)
                                    .where.not(user_id: current_user.id)
                                    .count
  end

  def set_user_role
    business_owner?
  end

  def business_owner?
    return false unless current_user
    @business_owner ||= current_user.businesses.exists?
  end

  def conversation_access_scope
    return Conversation.none unless current_user
    current_user.all_conversations
  end

  def storable_location?
    request.get? &&
      is_navigational_format? &&
      !devise_controller? &&
      !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end
