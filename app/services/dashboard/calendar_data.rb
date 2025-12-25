module Dashboard
  class CalendarData
    attr_reader :businesses,
                :selected_calendar_business_id,
                :calendar_date,
                :calendar_prev_date,
                :calendar_next_date,
                :calendar_weeks,
                :bookings_by_day,
                :booking

    def initialize(businesses, params = {}, booking: Booking.new)
      @businesses = businesses
      @params = params
      @booking = booking
      build
    end

    def locals
      {
        businesses: businesses,
        selected_calendar_business_id: selected_calendar_business_id,
        calendar_prev_date: calendar_prev_date,
        calendar_next_date: calendar_next_date,
        calendar_date: calendar_date,
        calendar_weeks: calendar_weeks,
        bookings_by_day: bookings_by_day,
        booking: booking
      }
    end

    private

    def build
      @calendar_date = extract_calendar_date
      calendar_start = @calendar_date.beginning_of_month.beginning_of_week(:monday)
      calendar_end = @calendar_date.end_of_month.end_of_week(:sunday)
      @calendar_prev_date = @calendar_date.prev_month
      @calendar_next_date = @calendar_date.next_month
      calendar_days = (calendar_start..calendar_end).to_a
      @calendar_weeks = calendar_days.each_slice(7).to_a

      @selected_calendar_business_id = @params[:calendar_business_id].presence
      calendar_businesses = if @selected_calendar_business_id.present?
                              @businesses.where(slug: @selected_calendar_business_id)
                            else
                              @businesses
                            end

      if calendar_businesses.any?
        range_start = calendar_start.beginning_of_day
        range_end = calendar_end.end_of_day
        calendar_bookings = Booking.includes(:business)
                                   .where(business: calendar_businesses)
                                   .between(range_start, range_end)
        @bookings_by_day = calendar_bookings.group_by { |b| b.start_time.in_time_zone.to_date }
      else
        @bookings_by_day = {}
      end
    end

    def extract_calendar_date
      if @params[:calendar_month].present? && @params[:calendar_year].present?
        Date.new(@params[:calendar_year].to_i, @params[:calendar_month].to_i, 1)
      else
        Date.current.beginning_of_month
      end
    rescue ArgumentError
      Date.current.beginning_of_month
    end
  end
end
