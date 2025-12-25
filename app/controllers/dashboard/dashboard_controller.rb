class Dashboard::DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @businesses = current_user.businesses.includes(:category, :city).order(:name)
    @recent_conversations = Conversation.includes(:business, :customer, messages: :user)
                                         .where(business: @businesses)
                                         .recent
                                         .limit(5)
    @business = @businesses.first || build_placeholder_business

    booking_overview = Dashboard::BookingOverview.new(current_user).fetch
    @owner_booking_requests = booking_overview.owner_bookings
    @customer_bookings = booking_overview.customer_bookings

    # Load reviews based on user type
    if @businesses.any?
      # Business owner: show reviews received on their businesses
      @recent_reviews = Review.includes(:business, :user)
                              .where(business: @businesses)
                              .order(created_at: :desc)
                              .limit(5)
      @reviews_type = :received
    else
      # Regular user: show reviews they left on other businesses
      @recent_reviews = Review.includes(:business, :user)
                              .where(user: current_user)
                              .order(created_at: :desc)
                              .limit(5)
      @reviews_type = :given
    end

    apply_calendar_data

    # Load payment details
    @payment_detail = current_user.payment_detail || current_user.build_payment_detail

    # Future: Load analytics, etc.
    # @recent_inquiries = current_user.businesses.joins(:inquiries).limit(5)
    # @analytics = DashboardAnalytics.new(current_user)
  end

  def update_payment_details
    @payment_detail = current_user.payment_detail || current_user.build_payment_detail

    if @payment_detail.update(payment_detail_params)
      redirect_to dashboard_root_path, notice: "Podaci za plaćanje su uspešno sačuvani."
    else
      redirect_to dashboard_root_path, alert: "Greška pri čuvanju podataka: #{@payment_detail.errors.full_messages.join(', ')}"
    end
  end

  private

  def apply_calendar_data
    calendar_data = Dashboard::CalendarData.new(@businesses, params)
    @selected_calendar_business_id = calendar_data.selected_calendar_business_id
    @calendar_date = calendar_data.calendar_date
    @calendar_prev_date = calendar_data.calendar_prev_date
    @calendar_next_date = calendar_data.calendar_next_date
    @calendar_weeks = calendar_data.calendar_weeks
    @bookings_by_day = calendar_data.bookings_by_day
    @booking = calendar_data.booking
  end

  def build_placeholder_business
    Business.new(
      name: "Vaš biznis",
      description: "Dodajte opis svog mesta i istaknite se među konkurencijom.",
      category: Category.new(name: "Kategorija", icon: "🏷️"),
      city: City.new(name: "Vaš grad")
    )
  end

  def payment_detail_params
    params.require(:payment_detail).permit(:bank_account_number, :account_owner_name, :account_owner_address)
  end
end
