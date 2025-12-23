class ExtendBookingsForPublicBooking < ActiveRecord::Migration[7.1]
  def change
    # Add customer reference for public bookings
    add_reference :bookings, :customer, null: true, foreign_key: { to_table: :users }

    # Add pricing plan reference for public bookings
    add_reference :bookings, :pricing_plan, null: true, foreign_key: true

    # Add new fields for booking management
    add_column :bookings, :customer_name, :string
    add_column :bookings, :customer_email, :string
    add_column :bookings, :customer_phone, :string
    add_column :bookings, :number_of_kids, :integer
    add_column :bookings, :number_of_adults, :integer
    add_column :bookings, :special_requests, :text
    add_column :bookings, :total_price, :decimal, precision: 10, scale: 2
    add_column :bookings, :currency, :string, default: 'RSD'

    # Update status to support new workflow
    # Old values: confirmed, tentative, cancelled
    # New values: requested, confirmed, pending_payment, completed, cancelled, rejected

    # Add booking type to distinguish between business-created vs customer-requested
    add_column :bookings, :booking_type, :string, default: 'business_created'

    # Add timestamps for status changes
    add_column :bookings, :requested_at, :datetime
    add_column :bookings, :confirmed_at, :datetime
    add_column :bookings, :completed_at, :datetime
    add_column :bookings, :cancelled_at, :datetime

    # Add indexes for performance (some may already exist)
    add_index :bookings, :booking_type unless index_exists?(:bookings, :booking_type)
    add_index :bookings, :status unless index_exists?(:bookings, :status)
  end
end