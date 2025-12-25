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
    @business_url = Rails.application.routes.url_helpers.venue_url(@business, host: mailer_host, protocol: mailer_protocol)

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
    @payment_detail = @business.user.payment_detail

    # Calculate 30% advance payment
    if @pricing_plan&.base_price
      @total_price = @pricing_plan.base_price
      @advance_payment_amount = (@total_price * 0.3).round
    end

    @business_url = Rails.application.routes.url_helpers.venue_url(@business, host: mailer_host, protocol: mailer_protocol)
    @dashboard_url = Rails.application.routes.url_helpers.dashboard_root_url(host: mailer_host, protocol: mailer_protocol)

    return if @customer_email.blank?

    mail(
      to: @customer_email,
      subject: "🎉 #{booking.business.display_name} je prihvatio vašu rezervaciju"
    )
  end

  def payment_confirmed_for_customer(booking)
    @booking = booking
    @business = booking.business
    @customer_name = booking.customer_name.presence || booking.customer&.full_name || "dragi roditelji"
    @customer_email = booking.customer_email.presence || booking.customer&.email
    @pricing_plan = booking.pricing_plan

    # Calculate amounts
    if @pricing_plan&.base_price
      @total_price = @pricing_plan.base_price
      @paid_amount = (@total_price * 0.3).round
      @remaining_amount = @total_price - @paid_amount
    end

    @business_url = Rails.application.routes.url_helpers.venue_url(@business, host: mailer_host, protocol: mailer_protocol)
    @dashboard_url = Rails.application.routes.url_helpers.dashboard_root_url(host: mailer_host, protocol: mailer_protocol)

    return if @customer_email.blank?

    mail(
      to: @customer_email,
      subject: "✅ Potvrda uplate za rezervaciju - #{booking.business.display_name}"
    )
  end

  private

  def format_datetime(value)
    return "-" unless value

    I18n.l(value, format: "%d.%m.%Y. %H:%M")
  end

  def mailer_host
    Rails.application.config.action_mailer.default_url_options[:host] ||
      ENV.fetch("APP_HOST", "localhost")
  end

  def mailer_protocol
    Rails.application.config.action_mailer.default_url_options[:protocol] ||
      (Rails.env.production? ? "https" : "http")
  end
end
