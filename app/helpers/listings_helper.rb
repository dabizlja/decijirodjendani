module ListingsHelper
  def format_price(amount, currency = "EUR")
    format_price_with_currency(amount, currency)
  end

  def pricing_plan_label(plan)
    case plan.plan_type.to_sym
    when :time_slot
      "Termin (#{format_duration(plan.duration_minutes)})"
    when :package
      "Paket"
    when :service
      "Usluga"
    when :addon
      "Dodatna opcija"
    else
      "Ponuda"
    end
  end

  def format_duration(minutes)
    return "fleksibilno" if minutes.blank?

    hours = minutes / 60
    mins = minutes % 60
    return "#{hours}h" if mins.zero?

    "#{hours}h #{mins}min"
  end
end
