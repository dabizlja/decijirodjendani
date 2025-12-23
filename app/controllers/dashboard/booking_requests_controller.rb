class Dashboard::BookingRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking

  def accept
    return unless authorize_owner!
    return unless ensure_customer_request!

    handle_action(%w[requested],
                  { status: "pending_payment" },
                  flash_type: :notice,
                  message: "Rezervacija je prihvaćena. Čeka potvrdu uplate.") do |booking|
      BookingMailer.booking_accepted_for_customer(booking)&.deliver_later
    end
  end

  def reject
    return unless authorize_owner!
    return unless ensure_customer_request!

    handle_action(%w[requested],
                  { status: "rejected" },
                  flash_type: :alert,
                  message: "Zahtev je odbijen.")
  end

  def cancel
    return unless authorize_owner!
    return unless ensure_customer_request!

    handle_action(%w[requested pending_payment confirmed],
                  { status: "cancelled", cancelled_at: Time.current },
                  flash_type: :alert,
                  message: "Rezervacija je otkazana.")
  end

  def mark_paid
    return unless authorize_owner!
    return unless ensure_customer_request!

    handle_action(%w[pending_payment],
                  { status: "confirmed", confirmed_at: Time.current },
                  flash_type: :notice,
                  message: "Uplata je evidentirana. Rezervacija je potvrđena.")
  end

  def complete
    return unless authorize_owner!
    return unless ensure_customer_request!

    handle_action(%w[confirmed],
                  { status: "completed", completed_at: Time.current },
                  flash_type: :notice,
                  message: "Rezervacija je označena kao završena.")
  end

  def customer_cancel
    return unless authorize_customer!
    return unless ensure_customer_request!

    handle_action(%w[requested pending_payment confirmed],
                  { status: "cancelled", cancelled_at: Time.current },
                  flash_type: :alert,
                  message: "Otkazali ste rezervaciju.")
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def authorize_owner!
    return true if @booking.business.user_id == current_user.id

    respond_unauthorized("Nemate dozvolu da menjate ovu rezervaciju.")
    false
  end

  def authorize_customer!
    return true if @booking.customer_id == current_user.id

    respond_unauthorized("Ova rezervacija ne pripada vašem nalogu.")
    false
  end

  def ensure_customer_request!
    return true if @booking.booking_type == "customer_requested"

    respond_with_overview(:alert,
                          "Ovu rezervaciju nije moguće menjati iz ovog pregleda.",
                          status: :unprocessable_entity,
                          update_lists: false)
    false
  end

  def handle_action(allowed_statuses, attrs, flash_type:, message:)
    unless allowed_statuses.include?(@booking.status)
      return respond_with_overview(:alert,
                                   "Ova akcija više nije dostupna.",
                                   status: :unprocessable_entity)
    end

    if @booking.update(attrs)
      yield(@booking) if block_given?
      respond_with_overview(flash_type, message)
    else
      respond_with_overview(:alert,
                            @booking.errors.full_messages.to_sentence,
                            status: :unprocessable_entity)
    end
  end

  def respond_with_overview(flash_type, message, status: :ok, update_lists: true)
    overview = Dashboard::BookingOverview.new(current_user).fetch
    response_streams = []
    if update_lists
      frame_markup = view_context.turbo_frame_tag("dashboard-bookings") do
        view_context.render(
          partial: "dashboard/dashboard/bookings_lists",
          locals: overview.locals
        )
      end
      response_streams << turbo_stream.replace("dashboard-bookings", frame_markup)
    end
    if message.present?
      response_streams << turbo_stream.prepend(
        "flash-messages",
        view_context.render(
          partial: "shared/flash_message",
          locals: { type: flash_type, message: message }
        )
      )
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: response_streams, status: status
      end
      format.html do
        redirect_to dashboard_root_path, flash_type => message
      end
    end
  end

  def respond_unauthorized(message)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.prepend(
          "flash-messages",
          view_context.render(
            partial: "shared/flash_message",
            locals: { type: :alert, message: message }
          )
        ), status: :forbidden
      end
      format.html do
        redirect_to dashboard_root_path, alert: message
      end
    end
  end
end
