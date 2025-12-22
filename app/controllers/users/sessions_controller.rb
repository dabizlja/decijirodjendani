class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    preload_home_context
    self.resource = resource_class.new
    clean_up_passwords(resource)
    @sign_in_user = resource
    @show_sign_in_modal = true
    render "pages/home", status: :ok
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate(auth_options)

    if resource
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      handle_failed_authentication
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  private

  def preload_home_context
    @user ||= User.new
    @categories ||= Category.where(active: true).order(:name)
    @cities ||= City.where(active: true).order(:name)
  end

  def sign_in_params
    params.fetch(:user, {}).permit(:email, :password, :remember_me)
  end

  def handle_failed_authentication
    self.resource = resource_class.new(sign_in_params)
    resource.validate # run validations to populate errors
    resource.errors.add(:base, I18n.t("devise.failure.invalid", authentication_keys: resource_class.authentication_keys.join(", ")))
    flash.now[:alert] = resource.errors.full_messages.to_sentence

    preload_home_context
    @sign_in_user = resource
    @show_sign_in_modal = true

    respond_to do |format|
      format.html { render "pages/home", status: :unprocessable_entity }
    end
  end
end
