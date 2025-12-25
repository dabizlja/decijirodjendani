class CreatePaymentDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_details do |t|
      t.references :user, null: false, foreign_key: true
      t.string :bank_account_number
      t.string :account_owner_name
      t.text :account_owner_address

      t.timestamps
    end
  end
end
