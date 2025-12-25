class Dashboard::BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_businesses, only: [:create, :edit, :update, :destroy]
  before_action :set_booking, only: [:edit, :update, :destroy]
  before_action :ensure_owner!, only: [:edit, :update, :destroy]

  def create
    business = @businesses.find(booking_params[:business_id])
    @booking = business.bookings.new(booking_params.except(:business_id))

    respond_to do |format|
      if @booking.save
        calendar_data = calendar_data_for(params, booking: @booking)
        format.turbo_stream { render_successful_creation_stream(calendar_data) }
        format.html do
          redirect_to dashboard_root_path(calendar_month: @booking.start_time.month,
                                          calendar_year: @booking.start_time.year,
                                          calendar_business_id: business.slug),
                      notice: "Termin je uspešno dodat."
        end
      else
        calendar_data = calendar_data_for(params, booking: @booking)
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "booking-modal",
            partial: "dashboard/bookings/modal",
            locals: modal_locals(calendar_data)
          )
        end
        format.html do
          redirect_back fallback_location: dashboard_root_path,
                        alert: @booking.errors.full_messages.to_sentence
        end
      end
    end
  end

  def edit
    calendar_context = params.permit(:calendar_month, :calendar_year, :calendar_business_id)
    calendar_month = calendar_context[:calendar_month].presence || @booking.start_time.month
    calendar_year = calendar_context[:calendar_year].presence || @booking.start_time.year
    respond_to do |format|
      format.html do
        render partial: "edit_form",
               locals: {
                 booking: @booking,
                 businesses: @businesses,
                 calendar_month: calendar_month,
                 calendar_year: calendar_year,
                 selected_calendar_business_id: calendar_context[:calendar_business_id]
               }
      end
      format.json { render json: @booking }
    end
  end

  def update
    respond_to do |format|
      if @booking.update(booking_params)
        calendar_data = calendar_data_for(params, booking: @booking)
        format.turbo_stream { render_successful_update_stream(calendar_data) }
        format.html do
          redirect_to dashboard_root_path(calendar_month: @booking.start_time.month,
                                          calendar_year: @booking.start_time.year,
                                          calendar_business_id: @booking.business.slug),
                      notice: "Termin je uspešno ažuriran."
        end
      else
        format.html { render partial: 'edit_form', locals: { booking: @booking, businesses: @businesses } }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @booking.destroy
    respond_to do |format|
      calendar_data = calendar_data_for(params, booking: @booking)
      format.turbo_stream { render_successful_deletion_stream(calendar_data) }
      format.html do
        redirect_to dashboard_root_path(calendar_month: calendar_data.calendar_date.month,
                                        calendar_year: calendar_data.calendar_date.year,
                                        calendar_business_id: calendar_data.selected_calendar_business_id),
                    notice: "Termin je obrisan."
      end
    end
  end

  private

  def booking_params
    params.require(:booking).permit(:business_id, :title, :start_time, :end_time, :notes)
  end

  def calendar_data_for(raw_params, booking: Booking.new)
    permitted = raw_params.is_a?(ActionController::Parameters) ? raw_params.permit(:calendar_month, :calendar_year, :calendar_business_id) : raw_params
    context = permitted.to_h.transform_keys(&:to_s)
    if context["calendar_month"].blank? && booking&.start_time
      context["calendar_month"] = booking.start_time.month
    end
    if context["calendar_year"].blank? && booking&.start_time
      context["calendar_year"] = booking.start_time.year
    end
    Dashboard::CalendarData.new(@businesses, context, booking: booking)
  end

  def modal_locals(calendar_data)
    calendar_data.locals.merge(
      calendar_month: calendar_data.calendar_date.month,
      calendar_year: calendar_data.calendar_date.year,
      selected_calendar_business_id: calendar_data.selected_calendar_business_id
    )
  end

  def render_successful_creation_stream(calendar_data)
    render turbo_stream: [
      turbo_stream.replace(
        "dashboard-calendar",
        partial: "dashboard/dashboard/calendar_frame_wrapper",
        locals: calendar_data.locals
      ),
      # Show success message
      turbo_stream.prepend("flash-messages") do
        <<~HTML.html_safe
          <div data-controller="flash"
               data-flash-timeout-value="5000"
               class="pointer-events-auto flex w-full max-w-2xl items-center gap-3 rounded-2xl border px-4 py-3 shadow-lg backdrop-blur bg-white/90 transition opacity-100 bg-green-50 border-green-200 text-green-800">
            <span class="text-xl">✅</span>
            <p class="flex-1 text-sm font-medium leading-relaxed text-gray-900">Termin je uspešno dodat!</p>
            <button type="button"
                    class="text-gray-400 hover:text-gray-600 transition"
                    aria-label="Zatvori obaveštenje"
                    data-action="flash#dismiss">
              ×
            </button>
          </div>
        HTML
      end,
      # Close the modal after successful creation by triggering the close action
      turbo_stream.after("booking-modal") do
        <<~HTML.html_safe
          <script>
            setTimeout(() => {
              const modal = document.querySelector('#booking-modal');
              if (modal) {
                modal.classList.add('hidden');
                modal.classList.remove('flex');
                modal.setAttribute('aria-hidden', 'true');
                delete modal.dataset.modalOpen;
                document.body.classList.remove('overflow-hidden');
              }
            }, 100);
          </script>
        HTML
      end
    ]
  end

  def render_successful_update_stream(calendar_data)
    render turbo_stream: [
      turbo_stream.replace(
        "dashboard-calendar",
        partial: "dashboard/dashboard/calendar_frame_wrapper",
        locals: calendar_data.locals
      ),
      # Show success message for update
      turbo_stream.prepend("flash-messages") do
        <<~HTML.html_safe
          <div data-controller="flash"
               data-flash-timeout-value="5000"
               class="pointer-events-auto flex w-full max-w-2xl items-center gap-3 rounded-2xl border px-4 py-3 shadow-lg backdrop-blur bg-white/90 transition opacity-100 bg-blue-50 border-blue-200 text-blue-800">
            <span class="text-xl">✏️</span>
            <p class="flex-1 text-sm font-medium leading-relaxed text-gray-900">Termin je uspešno ažuriran!</p>
            <button type="button"
                    class="text-gray-400 hover:text-gray-600 transition"
                    aria-label="Zatvori obaveštenje"
                    data-action="flash#dismiss">
              ×
            </button>
          </div>
        HTML
      end,
      # Close the edit modal after successful update
      turbo_stream.after("edit-booking-modal") do
        <<~HTML.html_safe
          <script>
            setTimeout(() => {
              const modal = document.querySelector('#edit-booking-modal');
              if (modal) {
                modal.classList.add('hidden');
                modal.classList.remove('flex');
                modal.setAttribute('aria-hidden', 'true');
                delete modal.dataset.modalOpen;
                document.body.classList.remove('overflow-hidden');
              }
            }, 100);
          </script>
        HTML
      end
    ]
  end

  def render_successful_deletion_stream(calendar_data)
    render turbo_stream: [
      turbo_stream.replace(
        "dashboard-calendar",
        partial: "dashboard/dashboard/calendar_frame_wrapper",
        locals: calendar_data.locals
      ),
      # Show success message for deletion
      turbo_stream.prepend("flash-messages") do
        <<~HTML.html_safe
          <div data-controller="flash"
               data-flash-timeout-value="5000"
               class="pointer-events-auto flex w-full max-w-2xl items-center gap-3 rounded-2xl border px-4 py-3 shadow-lg backdrop-blur bg-white/90 transition opacity-100 bg-red-50 border-red-200 text-red-800">
            <span class="text-xl">🗑️</span>
            <p class="flex-1 text-sm font-medium leading-relaxed text-gray-900">Termin je uspešno obrisan!</p>
            <button type="button"
                    class="text-gray-400 hover:text-gray-600 transition"
                    aria-label="Zatvori obaveštenje"
                    data-action="flash#dismiss">
              ×
            </button>
          </div>
        HTML
      end
    ]
  end

  def render_calendar_stream(calendar_data)
    render turbo_stream: [
      turbo_stream.replace(
        "dashboard-calendar",
        partial: "dashboard/dashboard/calendar_frame_wrapper",
        locals: calendar_data.locals
      ),
      turbo_stream.replace(
        "booking-modal",
        partial: "dashboard/bookings/modal",
        locals: modal_locals(calendar_data)
      )
    ]
  end

  def load_businesses
    @businesses = current_user.businesses.includes(:category, :city).order(:name)
  end

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def ensure_owner!
    unless current_user.businesses.exists?(id: @booking.business_id)
      respond_to do |format|
        format.html { redirect_to dashboard_root_path, alert: "Nemate dozvolu za ovu akciju." }
        format.json { render json: { error: "Nemate dozvolu za ovu akciju." }, status: :forbidden }
        format.any { head :forbidden }
      end
    end
  end
end
