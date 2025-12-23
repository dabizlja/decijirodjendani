class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEFAULT_FROM_EMAIL", "no-reply@rodjendani.rs")
  layout "mailer"
end
