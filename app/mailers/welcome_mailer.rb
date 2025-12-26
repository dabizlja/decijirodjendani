class WelcomeMailer < ApplicationMailer
  layout false

  def business_introduction(email)
    mail(
      to: email,
      subject: "Poziv za pridruživanje KidSpot platformi - Besplatna registracija za vaš biznis"
    )
  end
end
