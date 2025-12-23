class BookingsController < ApplicationController
  before_action :set_business, only: [:create]
  before_action :set_pricing_plan, only: [:create]

  def create
    @booking = @business.bookings.build(booking_params)
    @booking.booking_type = 'customer_requested'
    @booking.status = 'requested'
    @booking.requested_at = Time.current

    if @pricing_plan
      @booking.pricing_plan = @pricing_plan
      @booking.total_price = @pricing_plan.current_price
      @booking.currency = @pricing_plan.currency
    end

    ensure_end_time!

    # Set customer if logged in
    if user_signed_in?
      @booking.customer_id = current_user.id
      @booking.customer_name ||= current_user.full_name
      @booking.customer_email ||= current_user.email
    end

    if @booking.save
      # Send notification to business owner (we can implement this later)
      redirect_to venue_path(@business), notice: '🎉 Vaš zahtev za rezervaciju je uspešno poslat! Vlasnik objekta će vas kontaktirati.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_business
    @business = Business.find(params[:business_id])
  end

  def set_pricing_plan
    pricing_plan_id = params[:pricing_plan_id] || params.dig(:booking, :pricing_plan_id)
    @pricing_plan = @business.pricing_plans.find(pricing_plan_id) if pricing_plan_id.present?
  rescue ActiveRecord::RecordNotFound
    redirect_to venue_path(@business), alert: 'Izabrani paket nije pronađen.'
  end

  def ensure_end_time!
    return if @booking.start_time.blank?
    return if @booking.end_time.present?

    if @pricing_plan&.duration_minutes.present?
      @booking.end_time = @booking.start_time + @pricing_plan.duration_minutes.minutes
    else
      @booking.end_time = @booking.start_time + 2.hours
    end
  end

  def booking_params
    params.require(:booking).permit(
      :title,
      :start_time,
      :end_time,
      :customer_name,
      :customer_email,
      :customer_phone,
      :number_of_kids,
      :number_of_adults,
      :special_requests
    )
  end
end
