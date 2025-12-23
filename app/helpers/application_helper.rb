module ApplicationHelper
  def pricing_plan_human_name(type)
    case type.to_s
    when "time_slot"
      "Termin"
    when "package"
      "Paket"
    when "service"
      "Usluga"
    when "addon"
      "Dodatna opcija"
    else
      "Ponuda"
    end
  end

  def format_price_with_currency(amount, currency = "EUR")
    return "-" if amount.blank?

    precision = currency == "RSD" ? 0 : 2
    unit = currency == "RSD" ? "RSD " : "#{currency} "
    number_to_currency(amount, precision: precision, unit: unit)
  end

  def booking_status_badge(booking)
    status = booking.status.to_s
    styles = {
      "requested" => { text: "Na čekanju", icon: "⏳", classes: "bg-amber-50 text-amber-800 border-amber-200" },
      "pending_payment" => { text: "Čeka uplatu", icon: "💳", classes: "bg-yellow-50 text-yellow-800 border-yellow-200" },
      "confirmed" => { text: "Potvrđeno", icon: "✅", classes: "bg-green-50 text-green-800 border-green-200" },
      "completed" => { text: "Završeno", icon: "🎉", classes: "bg-blue-50 text-blue-800 border-blue-200" },
      "cancelled" => { text: "Otkazano", icon: "🚫", classes: "bg-red-50 text-red-800 border-red-200" },
      "rejected" => { text: "Odbijeno", icon: "❌", classes: "bg-gray-50 text-gray-700 border-gray-200" },
      "tentative" => { text: "Privremeno", icon: "🕒", classes: "bg-purple-50 text-purple-800 border-purple-200" }
    }
    data = styles[status] || { text: status.humanize, icon: "ℹ️", classes: "bg-gray-50 text-gray-700 border-gray-200" }
    content_tag :span,
                "#{data[:icon]} #{data[:text]}".html_safe,
                class: "inline-flex items-center gap-1 rounded-full border px-3 py-1 text-xs font-semibold #{data[:classes]}"
  end

  def format_booking_time_range(booking)
    start_time = booking.start_time&.in_time_zone
    return "Vreme nije definisano" unless start_time

    end_time = booking.end_time&.in_time_zone
    start_string = start_time.strftime("%d.%m.%Y %H:%M")
    return start_string unless end_time
    "#{start_string} – #{end_time.strftime('%H:%M')}"
  end

  def booking_action_button_classes(style = :primary)
    base = "inline-flex items-center gap-1 rounded-xl px-4 py-2 text-sm font-semibold transition focus:outline-none focus:ring-2 focus:ring-offset-2"
    case style
    when :primary
      "#{base} bg-gradient-to-r from-purple-600 to-pink-600 text-white hover:brightness-110 focus:ring-purple-500"
    when :ghost
      "#{base} border border-gray-200 text-gray-700 hover:bg-gray-50 focus:ring-gray-400"
    when :warning
      "#{base} bg-red-50 text-red-700 border border-red-200 hover:bg-red-100 focus:ring-red-400"
    else
      "#{base} border border-gray-200 text-gray-700 hover:bg-gray-50 focus:ring-gray-400"
    end
  end
end
