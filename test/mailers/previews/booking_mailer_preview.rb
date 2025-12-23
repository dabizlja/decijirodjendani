class BookingMailerPreview < ActionMailer::Preview
  def new_booking_for_owner
    BookingMailer.new_booking_for_owner(sample_booking)
  end

  def booking_accepted_for_customer
    BookingMailer.booking_accepted_for_customer(sample_booking)
  end

  private

  def sample_booking
    city = City.new(name: "Beograd")
    owner = User.new(full_name: "Vlasnik Igrališta", email: "owner@example.com")
    business = Business.new(
      display_name: "Igraonica Veseli Grad",
      city: city,
      user: owner
    )

    Booking.new(
      business: business,
      pricing_plan: PricingPlan.new(title: "VIP Rođendanska žurka"),
      title: "Rođendan Sare",
      start_time: 2.weeks.from_now.change(hour: 17, min: 0),
      end_time: 2.weeks.from_now.change(hour: 20, min: 0),
      customer_name: "Ana Nikolić",
      customer_email: "ana@example.com",
      customer_phone: "+381 60 123 4567",
      number_of_kids: 18,
      number_of_adults: 12,
      special_requests: "Želimo temu 'svemir'. Molim pripremite zdravije grickalice.",
      total_price: 24000,
      currency: "RSD"
    )
  end
end
