module Users
  class RegistrationsController < Devise::RegistrationsController
    def new
      if user_signed_in?
        redirect_to root_path, notice: "Već ste prijavljeni."
        return
      end

      build_resource({})
      @user = resource
      preload_home_context
      @show_registration_modal = true

      render "pages/home"
    end

    def create
      build_resource(sign_up_params)

      resource.save
      yield resource if block_given?

      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        @user = resource
        preload_home_context
        @show_registration_modal = true
        flash.now[:alert] = resource.errors.full_messages.to_sentence if resource.errors&.any?

        render "pages/home", status: :unprocessable_entity
      end
    end

    protected

    def after_sign_up_path_for(resource)
      stored_location_for(resource) || root_path
    end

    def after_inactive_sign_up_path_for(_resource)
      root_path
    end

    private

    def preload_home_context
      @categories = Category.where(active: true).order(:name)
      @cities = City.where(active: true).order(:name)
    end
  end
end
