class CreateDiscounts < ActiveRecord::Migration[7.2]
  def change
    create_table :discounts do |t|
      t.references :pricing_plan, null: false, foreign_key: true
      t.string :name
      t.string :label
      t.integer :percentage_off
      t.decimal :amount_off, precision: 10, scale: 2
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :active, default: true, null: false
      t.integer :usage_limit
      t.integer :used_count, default: 0, null: false

      t.timestamps
    end

    add_index :discounts, :active
    add_index :discounts, [:starts_at, :ends_at]
  end
end
