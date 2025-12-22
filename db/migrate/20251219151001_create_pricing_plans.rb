class CreatePricingPlans < ActiveRecord::Migration[7.2]
  def change
    create_table :pricing_plans do |t|
      t.references :business, null: false, foreign_key: true
      t.integer :plan_type, null: false, default: 0
      t.string :name, null: false
      t.text :description
      t.decimal :base_price, null: false, precision: 10, scale: 2
      t.string :currency, null: false, default: "EUR"
      t.integer :duration_minutes
      t.integer :capacity_kids
      t.integer :capacity_adults
      t.string :price_unit
      t.integer :minimum_quantity
      t.integer :maximum_quantity
      t.jsonb :metadata, null: false, default: {}
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :pricing_plans, :plan_type
    add_index :pricing_plans, :active
    add_index :pricing_plans, :metadata, using: :gin
  end
end
