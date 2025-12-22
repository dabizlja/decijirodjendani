class CreateBusinesses < ActiveRecord::Migration[7.2]
  def change
    create_table :businesses do |t|
      t.string :name, null: false
      t.text :description
      t.string :address
      t.string :phone
      t.string :email
      t.string :website
      t.text :images # Store multiple image URLs as JSON
      t.boolean :active, default: true
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true

      t.timestamps
    end

    add_index :businesses, :name
    add_index :businesses, :active
  end
end
