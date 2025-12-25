class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEFAULT_FROM_EMAIL", "no-reply@kidspot.rs")
  layout "mailer"
end
