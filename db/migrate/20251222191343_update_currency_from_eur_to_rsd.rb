class UpdateCurrencyFromEurToRsd < ActiveRecord::Migration[8.1]
  def up
    # Update existing businesses with EUR currency to RSD
    execute "UPDATE businesses SET price_currency = 'RSD' WHERE price_currency = 'EUR'"

    # Update existing pricing plans with EUR currency to RSD
    execute "UPDATE pricing_plans SET currency = 'RSD' WHERE currency = 'EUR'"

    # Update default values in schema
    change_column_default :businesses, :price_currency, "RSD"
    change_column_default :pricing_plans, :currency, "RSD"
  end

  def down
    # Revert existing businesses with RSD currency to EUR
    execute "UPDATE businesses SET price_currency = 'EUR' WHERE price_currency = 'RSD'"

    # Revert existing pricing plans with RSD currency to EUR
    execute "UPDATE pricing_plans SET currency = 'EUR' WHERE currency = 'RSD'"

    # Revert default values in schema
    change_column_default :businesses, :price_currency, "EUR"
    change_column_default :pricing_plans, :currency, "EUR"
  end
end