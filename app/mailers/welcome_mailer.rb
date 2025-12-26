class WelcomeMailer < ApplicationMailer
  layout false

  def business_introduction(email)
    # Attach business introduction photos
    attach_business_photos

    mail(
      to: email,
      subject: "Poziv za pridruživanje KidSpot platformi - Besplatna registracija za vaš biznis"
    )
  end

  private

  def attach_business_photos
    photos_dir = Rails.root.join('app/assets/images/business_intro')

    if Dir.exist?(photos_dir)
      Dir.glob(File.join(photos_dir, '*.{jpg,jpeg,png,gif}')).each do |photo_path|
        filename = File.basename(photo_path)
        attachments[filename] = File.read(photo_path)
      end
    end
  end
end
