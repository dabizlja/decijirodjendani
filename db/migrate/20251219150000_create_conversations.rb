class CreateConversations < ActiveRecord::Migration[7.2]
  def change
    create_table :conversations do |t|
      t.references :business, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.datetime :last_message_at

      t.timestamps
    end

    add_index :conversations, [:business_id, :customer_id], unique: true
  end
end
