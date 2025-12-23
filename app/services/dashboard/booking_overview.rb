module Dashboard
  class BookingOverview
    attr_reader :owner_bookings, :customer_bookings

    DEFAULT_LIMIT = 10

    def initialize(user, limit: DEFAULT_LIMIT)
      @user = user
      @limit = limit
    end

    def fetch
      @owner_bookings = owner_scope
      @customer_bookings = customer_scope
      self
    end

    def locals
      {
        owner_bookings: owner_bookings,
        customer_bookings: customer_bookings
      }
    end

    private

    attr_reader :user, :limit

    def owner_scope
      return Booking.none unless user&.businesses&.exists?

      Booking.includes(:customer, :pricing_plan, business: :city)
             .where(business: user.businesses)
             .where(booking_type: "customer_requested")
             .order(Arel.sql("COALESCE(requested_at, created_at) DESC"))
             .limit(limit)
    end

    def customer_scope
      return Booking.none unless user

      Booking.includes(:pricing_plan, business: :city)
             .where(customer: user)
             .order(Arel.sql("COALESCE(start_time, created_at) DESC"))
             .limit(limit)
    end
  end
end
