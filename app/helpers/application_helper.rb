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
end
