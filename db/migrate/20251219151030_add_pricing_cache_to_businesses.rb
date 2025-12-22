class AddPricingCacheToBusinesses < ActiveRecord::Migration[7.2]
  def change
    add_column :businesses, :min_price, :decimal, precision: 10, scale: 2
    add_column :businesses, :max_price, :decimal, precision: 10, scale: 2
    add_column :businesses, :price_currency, :string, default: "EUR", null: false
    add_column :businesses, :has_active_discount, :boolean, default: false, null: false
  end
end
