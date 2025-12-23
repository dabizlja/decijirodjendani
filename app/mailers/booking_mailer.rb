class BookingMailer < ApplicationMailer
  helper ActionView::Helpers::NumberHelper
  helper_method :format_datetime

  def new_booking_for_owner(booking)
    @booking = booking
    @business = booking.business
    @customer_name = booking.customer_name.presence || booking.customer&.full_name || "Novi gost"
    @customer_email = booking.customer_email.presence || booking.customer&.email
    @customer_phone = booking.customer_phone
    @pricing_plan = booking.pricing_plan
    @business_url = Rails.application.routes.url_helpers.venue_url(@business)

    recipient = @business.user&.email
    return if recipient.blank?

    mail(
      to: recipient,
      subject: "📩 Novi zahtev za #{@business.display_name}"
    )
  end

  def booking_accepted_for_customer(booking)
    @booking = booking
    @business = booking.business
    @customer_name = booking.customer_name.presence || booking.customer&.full_name || "dragi roditelji"
    @customer_email = booking.customer_email.presence || booking.customer&.email
    @pricing_plan = booking.pricing_plan
    @business_url = Rails.application.routes.url_helpers.venue_url(@business)
    @dashboard_url = Rails.application.routes.url_helpers.dashboard_root_url

    return if @customer_email.blank?

    mail(
      to: @customer_email,
      subject: "🎉 #{booking.business.display_name} je prihvatio vašu rezervaciju"
    )
  end

  private

  def format_datetime(value)
    return "-" unless value

    I18n.l(value, format: "%d.%m.%Y. %H:%M")
  end
end
