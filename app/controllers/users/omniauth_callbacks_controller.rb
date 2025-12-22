module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      auth = request.env["omniauth.auth"]
      @user = User.from_omniauth(auth)

      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
      sign_in_and_redirect @user, event: :authentication
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("[OmniauthCallbacks] Google sign in failed: #{e.record.errors.full_messages.to_sentence}")
      redirect_to new_user_registration_url, alert: e.record.errors.full_messages.to_sentence
    rescue StandardError => e
      Rails.logger.error("[OmniauthCallbacks] Google sign in error: #{e.message}")
      redirect_to new_user_registration_url, alert: "Nismo uspeli da te prijavimo preko Google naloga. Pokušaj ponovo."
    end

    def failure
      redirect_to root_path, alert: "Prijava nije uspela. Molimo pokušaj ponovo."
    end
  end
end
