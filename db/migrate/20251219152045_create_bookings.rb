class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      t.references :business, null: false, foreign_key: true
      t.string :title, null: false, default: ""
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.string :status, null: false, default: "confirmed"
      t.text :notes

      t.timestamps
    end

    add_index :bookings, [:business_id, :start_time]
  end
end
